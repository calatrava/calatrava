/* Copyright (c) 2010 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#if !STRIP_GTM_FETCH_LOGGING

#include <sys/stat.h>
#include <unistd.h>

#import "GTMHTTPFetcherLogging.h"

// If GTMProgressMonitorInputStream is available, it can be used for
// capturing uploaded streams of data
//
// We locally declare some methods of GTMProgressMonitorInputStream so we
// do not need to import the header, as some projects may not have it available
@interface GTMProgressMonitorInputStream : NSInputStream
+ (id)inputStreamWithStream:(NSInputStream *)input
                     length:(unsigned long long)length;
- (void)setMonitorDelegate:(id)monitorDelegate;
- (void)setMonitorSelector:(SEL)monitorSelector;
- (void)setReadSelector:(SEL)readSelector;
- (void)setRunLoopModes:(NSArray *)modes;
@end

// If GTMNSJSONSerialization is available, it is used for formatting JSON
@interface GTMNSJSONSerialization : NSObject
+ (NSData *)dataWithJSONObject:(id)obj options:(NSUInteger)opt error:(NSError **)error;
+ (id)JSONObjectWithData:(NSData *)data options:(NSUInteger)opt error:(NSError **)error;
@end

// Otherwise, if SBJSON is available, it is used for formatting JSON
@interface GTMFetcherSBJSON
- (void)setHumanReadable:(BOOL)flag;
- (NSString*)stringWithObject:(id)value error:(NSError**)error;
- (id)objectWithString:(NSString*)jsonrep error:(NSError**)error;
@end

@interface GTMHTTPFetcher (GTMHTTPFetcherLoggingInternal)
+ (NSString *)headersStringForDictionary:(NSDictionary *)dict
                             alignColons:(BOOL)shouldAlignColons;

- (void)inputStream:(GTMProgressMonitorInputStream *)stream
     readIntoBuffer:(void *)buffer
             length:(unsigned long long)length;

// internal file utilities for logging
+ (BOOL)fileOrDirExistsAtPath:(NSString *)path;
+ (BOOL)makeDirectoryUpToPath:(NSString *)path;
+ (BOOL)removeItemAtPath:(NSString *)path;
+ (BOOL)createSymbolicLinkAtPath:(NSString *)newPath
             withDestinationPath:(NSString *)targetPath;

+ (NSString *)snipSubtringOfString:(NSString *)originalStr
                betweenStartString:(NSString *)startStr
                         endString:(NSString *)endStr;

+ (id)JSONObjectWithData:(NSData *)data;
+ (id)stringWithJSONObject:(id)obj;
@end

@implementation GTMHTTPFetcher (GTMHTTPFetcherLogging)

// fetchers come and fetchers go, but statics are forever
static BOOL gIsLoggingEnabled = NO;
static BOOL gIsLoggingToFile = YES;
static NSString *gLoggingDirectoryPath = nil;
static NSString *gLoggingDateStamp = nil;
static NSString* gLoggingProcessName = nil;

+ (void)setLoggingDirectory:(NSString *)path {
  [gLoggingDirectoryPath autorelease];
  gLoggingDirectoryPath = [path copy];
}

+ (NSString *)loggingDirectory {

  if (!gLoggingDirectoryPath) {
    NSArray *arr = nil;
#if GTM_IPHONE && TARGET_IPHONE_SIMULATOR
    // default to a directory called GTMHTTPDebugLogs into a sandbox-safe
    // directory that a developer can find easily, the application home
    arr = [NSArray arrayWithObject:NSHomeDirectory()];
#elif GTM_IPHONE
    // Neither ~/Desktop nor ~/Home is writable on an actual iPhone device.
    // Put it in ~/Documents.
    arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                              NSUserDomainMask, YES);
#else
    // default to a directory called GTMHTTPDebugLogs in the desktop folder
    arr = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory,
                                              NSUserDomainMask, YES);
#endif

    if ([arr count] > 0) {
      NSString *const kGTMLogFolderName = @"GTMHTTPDebugLogs";

      NSString *desktopPath = [arr objectAtIndex:0];
      NSString *logsFolderPath = [desktopPath stringByAppendingPathComponent:kGTMLogFolderName];

      BOOL doesFolderExist = [[self class] fileOrDirExistsAtPath:logsFolderPath];

      if (!doesFolderExist) {
        // make the directory
        doesFolderExist = [self makeDirectoryUpToPath:logsFolderPath];
      }

      if (doesFolderExist) {
        // it's there; store it in the global
        gLoggingDirectoryPath = [logsFolderPath copy];
      }
    }
  }
  return gLoggingDirectoryPath;
}

+ (void)setLoggingEnabled:(BOOL)flag {
  gIsLoggingEnabled = flag;
}

+ (BOOL)isLoggingEnabled {
  return gIsLoggingEnabled;
}

+ (void)setLoggingToFileEnabled:(BOOL)flag {
  gIsLoggingToFile = flag;
}

+ (BOOL)isLoggingToFileEnabled {
  return gIsLoggingToFile;
}

+ (void)setLoggingProcessName:(NSString *)str {
  [gLoggingProcessName release];
  gLoggingProcessName = [str copy];
}

+ (NSString *)loggingProcessName {

  // get the process name (once per run) replacing spaces with underscores
  if (!gLoggingProcessName) {

    NSString *procName = [[NSProcessInfo processInfo] processName];
    NSMutableString *loggingProcessName;
    loggingProcessName = [[NSMutableString alloc] initWithString:procName];

    [loggingProcessName replaceOccurrencesOfString:@" "
                                        withString:@"_"
                                           options:0
                                             range:NSMakeRange(0, [gLoggingProcessName length])];
    gLoggingProcessName = loggingProcessName;
  }
  return gLoggingProcessName;
}

+ (void)setLoggingDateStamp:(NSString *)str {
  [gLoggingDateStamp release];
  gLoggingDateStamp = [str copy];
}

+ (NSString *)loggingDateStamp {
  // we'll pick one date stamp per run, so a run that starts at a later second
  // will get a unique results html file
  if (!gLoggingDateStamp) {
    // produce a string like 08-21_01-41-23PM

    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateFormat:@"M-dd_hh-mm-ssa"];

    gLoggingDateStamp = [[formatter stringFromDate:[NSDate date]] retain] ;
  }
  return gLoggingDateStamp;
}

// formattedStringFromData returns a prettyprinted string for XML or JSON input,
// and a plain string for other input data
- (NSString *)formattedStringFromData:(NSData *)inputData
                          contentType:(NSString *)contentType
                                 JSON:(NSDictionary **)outJSON {
  if (inputData == nil) return nil;

  // if the content type is JSON and we have the parsing class available,
  // use that
  if ([contentType hasPrefix:@"application/json"]
      && [inputData length] > 5) {
    // convert from JSON string to NSObjects and back to a formatted string
    NSMutableDictionary *obj = [[self class] JSONObjectWithData:inputData];
    if (obj) {
      if (outJSON) *outJSON = obj;
      if ([obj isKindOfClass:[NSMutableDictionary class]]) {
        // for security and privacy, omit OAuth 2 response access and refresh
        // tokens
        if ([obj valueForKey:@"refresh_token"] != nil) {
          [obj setObject:@"_snip_" forKey:@"refresh_token"];          
        }
        if ([obj valueForKey:@"access_token"] != nil) {
          [obj setObject:@"_snip_" forKey:@"access_token"];
        }
      }
      NSString *formatted = [[self class] stringWithJSONObject:obj];
      if (formatted) return formatted;
    }
  }

#if !GTM_FOUNDATION_ONLY && !GTM_SKIP_LOG_XMLFORMAT
  // verify that this data starts with the bytes indicating XML

  NSString *const kXMLLintPath = @"/usr/bin/xmllint";
  static BOOL hasCheckedAvailability = NO;
  static BOOL isXMLLintAvailable;

  if (!hasCheckedAvailability) {
    isXMLLintAvailable = [[self class] fileOrDirExistsAtPath:kXMLLintPath];
    hasCheckedAvailability = YES;
  }

  if (isXMLLintAvailable
      && [inputData length] > 5
      && strncmp([inputData bytes], "<?xml", 5) == 0) {

    // call xmllint to format the data
    NSTask *task = [[[NSTask alloc] init] autorelease];
    [task setLaunchPath:kXMLLintPath];

    // use the dash argument to specify stdin as the source file
    [task setArguments:[NSArray arrayWithObjects:@"--format", @"-", nil]];
    [task setEnvironment:[NSDictionary dictionary]];

    NSPipe *inputPipe = [NSPipe pipe];
    NSPipe *outputPipe = [NSPipe pipe];
    [task setStandardInput:inputPipe];
    [task setStandardOutput:outputPipe];

    [task launch];

    [[inputPipe fileHandleForWriting] writeData:inputData];
    [[inputPipe fileHandleForWriting] closeFile];

    // drain the stdout before waiting for the task to exit
    NSData *formattedData =
    [[outputPipe fileHandleForReading] readDataToEndOfFile];

    [task waitUntilExit];

    int status = [task terminationStatus];
    if (status == 0 && [formattedData length] > 0) {
      // success
      inputData = formattedData;
    }
  }
#else
  // we can't call external tasks on the iPhone; leave the XML unformatted
#endif

  NSString *dataStr = [[[NSString alloc] initWithData:inputData
                                             encoding:NSUTF8StringEncoding] autorelease];
  return dataStr;
}

- (void)setupStreamLogging {
  // if logging is enabled, it needs a buffer to accumulate data from any
  // NSInputStream used for uploading.  Logging will wrap the input
  // stream with a stream that lets us keep a copy the data being read.
  if ([GTMHTTPFetcher isLoggingEnabled] && postStream_ != nil) {
    loggedStreamData_ = [[NSMutableData alloc] init];

    BOOL didCapture = [self logCapturePostStream];
    if (!didCapture) {
      // upload stream logging requires the class
      // GTMProgressMonitorInputStream be available
      NSString const *str = @"<<Uploaded stream data logging unavailable>>";
      [loggedStreamData_ setData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    }
  }
}

// stringFromStreamData creates a string given the supplied data
//
// If NSString can create a UTF-8 string from the data, then that is returned.
//
// Otherwise, this routine tries to find a MIME boundary at the beginning of
// the data block, and uses that to break up the data into parts. Each part
// will be used to try to make a UTF-8 string.  For parts that fail, a
// replacement string showing the part header and <<n bytes>> is supplied
// in place of the binary data.

- (NSString *)stringFromStreamData:(NSData *)data
                       contentType:(NSString *)contentType {

  if (data == nil) return nil;

  // optimistically, see if the whole data block is UTF-8
  NSString *streamDataStr = [self formattedStringFromData:data
                                              contentType:contentType
                                                     JSON:NULL];
  if (streamDataStr) return streamDataStr;

  // Munge a buffer by replacing non-ASCII bytes with underscores,
  // and turn that munged buffer an NSString.  That gives us a string
  // we can use with NSScanner.
  NSMutableData *mutableData = [NSMutableData dataWithData:data];
  unsigned char *bytes = [mutableData mutableBytes];

  for (unsigned int idx = 0; idx < [mutableData length]; idx++) {
    if (bytes[idx] > 0x7F || bytes[idx] == 0) {
      bytes[idx] = '_';
    }
  }

  NSString *mungedStr = [[[NSString alloc] initWithData:mutableData
                                   encoding:NSUTF8StringEncoding] autorelease];
  if (mungedStr != nil) {

    // scan for the boundary string
    NSString *boundary = nil;
    NSScanner *scanner = [NSScanner scannerWithString:mungedStr];

    if ([scanner scanUpToString:@"\r\n" intoString:&boundary]
        && [boundary hasPrefix:@"--"]) {

      // we found a boundary string; use it to divide the string into parts
      NSArray *mungedParts = [mungedStr componentsSeparatedByString:boundary];

      // look at each of the munged parts in the original string, and try to
      // convert those into UTF-8
      NSMutableArray *origParts = [NSMutableArray array];
      NSUInteger offset = 0;
      for (NSString *mungedPart in mungedParts) {
        NSUInteger partSize = [mungedPart length];

        NSRange range = NSMakeRange(offset, partSize);
        NSData *origPartData = [data subdataWithRange:range];

        NSString *origPartStr = [[[NSString alloc] initWithData:origPartData
                                   encoding:NSUTF8StringEncoding] autorelease];
        if (origPartStr) {
          // we could make this original part into UTF-8; use the string
          [origParts addObject:origPartStr];
        } else {
          // this part can't be made into UTF-8; scan the header, if we can
          NSString *header = nil;
          NSScanner *headerScanner = [NSScanner scannerWithString:mungedPart];
          if (![headerScanner scanUpToString:@"\r\n\r\n" intoString:&header]) {
            // we couldn't find a header
            header = @"";;
          }

          // make a part string with the header and <<n bytes>>
          NSString *binStr = [NSString stringWithFormat:@"\r%@\r<<%lu bytes>>\r",
            header, (long)(partSize - [header length])];
          [origParts addObject:binStr];
        }
        offset += partSize + [boundary length];
      }

      // rejoin the original parts
      streamDataStr = [origParts componentsJoinedByString:boundary];
    }
  }

  if (!streamDataStr) {
    // give up; just make a string showing the uploaded bytes
    streamDataStr = [NSString stringWithFormat:@"<<%u bytes>>",
                     (unsigned int)[data length]];
  }
  return streamDataStr;
}

// logFetchWithError is called following a successful or failed fetch attempt
//
// This method does all the work for appending to and creating log files

- (void)logFetchWithError:(NSError *)error {

  if (![[self class] isLoggingEnabled]) return;

  // TODO: (grobbins)  add Javascript to display response data formatted in hex

  NSString *parentDir = [[self class] loggingDirectory];
  NSString *processName = [[self class] loggingProcessName];
  NSString *dateStamp = [[self class] loggingDateStamp];

  // make a directory for this run's logs, like
  //   SyncProto_logs_10-16_01-56-58PM
  NSString *dirName = [NSString stringWithFormat:@"%@_log_%@",
                       processName, dateStamp];
  NSString *logDirectory = [parentDir stringByAppendingPathComponent:dirName];
  if (gIsLoggingToFile && ![[self class] makeDirectoryUpToPath:logDirectory]) return;

  // each response's NSData goes into its own xml or txt file, though all
  // responses for this run of the app share a main html file.  This
  // counter tracks all fetch responses for this run of the app.
  //
  // we'll use a local variable since this routine may be reentered while
  // waiting for XML formatting to be completed by an external task
  static int zResponseCounter = 0;
  int responseCounter = ++zResponseCounter;

  // file name for the html file containing plain text in a <textarea>
  NSString *responseDataUnformattedFileName = nil;

  // file name for the "formatted" (raw) data file
  NSString *responseDataFormattedFileName = nil;
  NSUInteger responseDataLength;
  if (downloadFileHandle_) {
    responseDataLength = (NSUInteger) [downloadFileHandle_ offsetInFile];
  } else {
    responseDataLength = [downloadedData_ length];
  }

  NSURLResponse *response = [self response];
  NSDictionary *responseHeaders = [self responseHeaders];

  NSString *responseBaseName = nil;
  NSString *responseDataStr = nil;
  NSDictionary *responseJSON = nil;

  // if there's response data, decide what kind of file to put it in based
  // on the first bytes of the file or on the mime type supplied by the server
  if (responseDataLength > 0) {
    NSString *responseDataExtn = nil;

    // generate a response file base name like
    responseBaseName = [NSString stringWithFormat:@"http_response_%d",
                        responseCounter];

    NSString *responseType = [responseHeaders valueForKey:@"Content-Type"];
    responseDataStr = [self formattedStringFromData:downloadedData_
                                        contentType:responseType
                                               JSON:&responseJSON];
    if (responseDataStr) {
      // we were able to make a UTF-8 string from the response data

      NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
      responseDataStr = [responseDataStr stringByTrimmingCharactersInSet:whitespaceSet];

      // save a plain-text version of the response data in an html file
      // containing a wrapped, scrollable <textarea>
      //
      // we'll use <textarea rows="29" cols="108" readonly=true wrap=soft>
      //   </textarea>  to fit inside our iframe
      responseDataUnformattedFileName = [responseBaseName stringByAppendingPathExtension:@"html"];
      NSString *textFilePath = [logDirectory stringByAppendingPathComponent:responseDataUnformattedFileName];

      NSString* wrapFmt = @"<textarea rows=\"29\" cols=\"108\" readonly=true"
        " wrap=soft>\n%@\n</textarea>";
      NSString* wrappedStr = [NSString stringWithFormat:wrapFmt, responseDataStr];
      {
        NSError *wrappedStrError = nil;
        if (gIsLoggingToFile
            && ![wrappedStr writeToFile:textFilePath
                             atomically:NO
                               encoding:NSUTF8StringEncoding
                                  error:&wrappedStrError]) {
              NSLog(@"%@ logging write error:%@ (%@)",
                    [self class], wrappedStrError, responseDataUnformattedFileName);
        }
      }

      // now determine the extension for the "formatted" file, which is really
      // the raw data written with an appropriate extension

      // for known file types, we'll write the data to a file with the
      // appropriate extension
      if ([responseDataStr hasPrefix:@"<?xml"]) {
        responseDataExtn = @"xml";
      } else if ([responseDataStr hasPrefix:@"<html"]) {
        responseDataExtn = @"html";
      } else {
        // add more types of identifiable text here
      }

    } else if ([[response MIMEType] isEqual:@"image/jpeg"]) {
      responseDataExtn = @"jpg";
    } else if ([[response MIMEType] isEqual:@"image/gif"]) {
      responseDataExtn = @"gif";
    } else if ([[response MIMEType] isEqual:@"image/png"]) {
      responseDataExtn = @"png";
    } else {
     // add more non-text types here
    }

    // if we have an extension, save the raw data in a file with that
    // extension to be our "formatted" display file
    if (responseDataExtn && downloadedData_) {
      responseDataFormattedFileName = [responseBaseName stringByAppendingPathExtension:responseDataExtn];
      NSString *formattedFilePath = [logDirectory stringByAppendingPathComponent:responseDataFormattedFileName];

      NSError *downloadedError = nil;
      if (gIsLoggingToFile
          && ![downloadedData_ writeToFile:formattedFilePath
                                   options:0
                                     error:&downloadedError]) {
            NSLog(@"%@ logging write error:%@ (%@)",
                  [self class], downloadedError, responseDataFormattedFileName);
          }
    }
  }

  // we'll have one main html file per run of the app
  NSString *htmlName = @"http_log.html";
  NSString *htmlPath =[logDirectory stringByAppendingPathComponent:htmlName];

  // if the html file exists (from logging previous fetches) we don't need
  // to re-write the header or the scripts
  BOOL didFileExist = [[self class] fileOrDirExistsAtPath:htmlPath];

  NSMutableString* outputHTML = [NSMutableString string];
  NSURLRequest *request = [self mutableRequest];

  // we need file names for the various div's that we're going to show and hide,
  // names unique to this response's bundle of data, so we format our div
  // names with the counter that we incremented earlier
  NSString *requestHeadersName = [NSString stringWithFormat:@"RequestHeaders%d", responseCounter];
  NSString *postDataName = [NSString stringWithFormat:@"PostData%d", responseCounter];

  NSString *responseHeadersName = [NSString stringWithFormat:@"ResponseHeaders%d", responseCounter];
  NSString *responseDataDivName = [NSString stringWithFormat:@"ResponseData%d", responseCounter];
  NSString *dataIFrameID = [NSString stringWithFormat:@"DataIFrame%d", responseCounter];

  // we need a header to say we'll have UTF-8 text
  if (!didFileExist) {
    [outputHTML appendFormat:@"<html><head><meta http-equiv=\"content-type\" "
      "content=\"text/html; charset=UTF-8\"><title>%@ HTTP fetch log %@</title>",
      processName, dateStamp];
  }

  // write style sheets for each hideable element; each style sheet is
  // customized with our current response number, since they'll share
  // the html page with other responses
  NSString *styleFormat = @"<style type=\"text/css\">div#%@ "
    "{ margin: 0px 20px 0px 20px; display: none; }</style>\n";

  [outputHTML appendFormat:styleFormat, requestHeadersName];
  [outputHTML appendFormat:styleFormat, postDataName];
  [outputHTML appendFormat:styleFormat, responseHeadersName];
  [outputHTML appendFormat:styleFormat, responseDataDivName];

  if (!didFileExist) {
    // write javascript functions.  The first one shows/hides the layer
    // containing the iframe.
    NSString *scriptFormat = @"<script type=\"text/javascript\"> "
      "function toggleLayer(whichLayer){ var style2 = document.getElementById(whichLayer).style; "
      "style2.display = style2.display ? \"\":\"block\";}</script>\n";
    [outputHTML appendString:scriptFormat];

    // the second function is passed the src file; if it's what's shown, it
    // toggles the iframe's visibility. If some other src is shown, it shows
    // the iframe and loads the new source.  Note we want to load the source
    // whenever we show the iframe too since Firefox seems to format it wrong
    // when showing it if we don't reload it.
    NSString *toggleIFScriptFormat = @"<script type=\"text/javascript\"> "
      "function toggleIFrame(whichLayer,iFrameID,newsrc)"
      "{ \n var iFrameElem=document.getElementById(iFrameID); "
      "if (iFrameElem.src.indexOf(newsrc) != -1) { toggleLayer(whichLayer); } "
      "else { document.getElementById(whichLayer).style.display=\"block\"; } "
      "iFrameElem.src=newsrc; }</script>\n</head>\n<body>\n";
    [outputHTML appendString:toggleIFScriptFormat];
  }

  // now write the visible html elements

  NSString *copyableFileName = [NSString stringWithFormat:@"copyable_%d.txt",
                                responseCounter];

  // write the date & time, the comment, and the link to the plain-text
  // (copyable) log
  NSString *dateLineFormat = @"<b>%@ &nbsp;&nbsp;&nbsp;&nbsp; ";
  [outputHTML appendFormat:dateLineFormat, [NSDate date]];

  NSString *comment = [self comment];
  if (comment) {
    NSString *commentFormat = @"%@ &nbsp;&nbsp;&nbsp;&nbsp; ";
    [outputHTML appendFormat:commentFormat, comment];
  }

  NSString *reqRespFormat = @"</b><a href='%@'><i>request/response</i></a><br>";
  [outputHTML appendFormat:reqRespFormat, copyableFileName];

  // write the request URL
  NSString *requestMethod = [request HTTPMethod];
  NSURL *requestURL = [request URL];
  [outputHTML appendFormat:@"<b>request:</b> %@ <i>URL:</i> "
    "<code>%@</code><br>\n", requestMethod, requestURL];

  // write the request headers, toggleable
  NSDictionary *requestHeaders = [request allHTTPHeaderFields];
  if ([requestHeaders count]) {
    NSString *requestHeadersFormat = @"<a href=\"javascript:toggleLayer('%@');\">"
      "request headers (%d)</a><div id=\"%@\"><pre>%@</pre></div><br>\n";
    [outputHTML appendFormat:requestHeadersFormat,
      requestHeadersName, // layer name
      (int)[requestHeaders count],
      requestHeadersName,
     [[self class] headersStringForDictionary:requestHeaders
                                  alignColons:YES]];
  } else {
    [outputHTML appendString:@"<i>Request headers: none</i><br>"];
  }

  // write the request post data, toggleable
  NSData *postData = postData_;
  if (loggedStreamData_) {
    postData = loggedStreamData_;
  }

  NSString *postDataStr = nil;
  NSUInteger postDataLength = [postData length];
  NSString *postType = [requestHeaders valueForKey:@"Content-Type"];

  if (postDataLength > 0) {
    NSString *postDataFormat = @"<a href=\"javascript:toggleLayer('%@');\">"
      "posted data (%d bytes)</a><div id=\"%@\">%@</div><br>\n";
    postDataStr = [self stringFromStreamData:postData
                                 contentType:postType];
    if (postDataStr) {
      NSString *postDataTextAreaFmt = @"<pre>%@</pre>";
      if ([postDataStr rangeOfString:@"<"].location != NSNotFound) {
        postDataTextAreaFmt =  @"<textarea rows=\"15\" cols=\"100\""
         " readonly=true wrap=soft>\n%@\n</textarea>";
      }

      // remove OAuth 2 client secret and refresh token
      postDataStr = [[self class] snipSubtringOfString:postDataStr
                                    betweenStartString:@"client_secret="
                                             endString:@"&"];

      postDataStr = [[self class] snipSubtringOfString:postDataStr
                                    betweenStartString:@"refresh_token="
                                             endString:@"&"];

      // remove ClientLogin password
      postDataStr = [[self class] snipSubtringOfString:postDataStr
                                    betweenStartString:@"&Passwd="
                                             endString:@"&"];
      NSString *postDataTextArea = [NSString stringWithFormat:
        postDataTextAreaFmt, postDataStr];

      [outputHTML appendFormat:postDataFormat,
        postDataName, // layer name
        [postData length],
        postDataName,
        postDataTextArea];
    }
  } else {
    // no post data
  }

  // write the response status, MIME type, URL
  NSInteger status = [self statusCode];
  if (response) {
    NSString *statusString = @"";
    if (status != 0) {
      if (status == 200 || status == 201) {
        statusString = [NSString stringWithFormat:@"%ld", (long)status];

        // report any JSON-RPC error
        if ([responseJSON isKindOfClass:[NSDictionary class]]) {
          NSDictionary *jsonError = [responseJSON objectForKey:@"error"];
          if ([jsonError isKindOfClass:[NSDictionary class]]) {
            NSString *jsonCode = [[jsonError valueForKey:@"code"] description];
            NSString *jsonMessage = [jsonError valueForKey:@"message"];
            if (jsonCode || jsonMessage) {
              NSString *jsonErrFmt = @"&nbsp;&nbsp;&nbsp;<i>JSON error:</i> <FONT"
                @" COLOR=\"#FF00FF\">%@ %@</FONT>";
              statusString = [statusString stringByAppendingFormat:jsonErrFmt,
                              jsonCode ? jsonCode : @"",
                              jsonMessage ? jsonMessage : @""];
            }
          }
        }
      } else {
        // purple for anything other than 200 or 201
        NSString *statusFormat = @"<FONT COLOR=\"#FF00FF\">%ld</FONT>";
        statusString = [NSString stringWithFormat:statusFormat, (long)status];
      }
    }

    // show the response URL only if it's different from the request URL
    NSString *responseURLStr =  @"";
    NSURL *responseURL = [response URL];

    if (responseURL && ![responseURL isEqual:[request URL]]) {
      NSString *responseURLFormat = @"<br><FONT COLOR=\"#FF00FF\">response URL:"
        "</FONT> <code>%@</code>";
      responseURLStr = [NSString stringWithFormat:responseURLFormat,
        [responseURL absoluteString]];
    }

    [outputHTML appendFormat:@"<b>response:</b> <i>status:</i> %@ <i>  "
        "&nbsp;&nbsp;&nbsp;MIMEType:</i><code> %@</code>%@<br>\n",
      statusString,
      [response MIMEType],
      responseURLStr,
     [[self class] headersStringForDictionary:responseHeaders
                                  alignColons:YES]];

    // write the response headers, toggleable
    if ([responseHeaders count]) {

      NSString *cookiesSet = [responseHeaders objectForKey:@"Set-Cookie"];

      NSString *responseHeadersFormat = @"<a href=\"javascript:toggleLayer("
        "'%@');\">response headers (%d)  %@</a><div id=\"%@\"><pre>%@</pre>"
        "</div><br>\n";
      [outputHTML appendFormat:responseHeadersFormat,
        responseHeadersName,
        (int)[responseHeaders count],
        (cookiesSet ? @"<i>sets cookies</i>" : @""),
        responseHeadersName,
       [[self class] headersStringForDictionary:responseHeaders
                                    alignColons:YES]];

    } else {
      [outputHTML appendString:@"<i>Response headers: none</i><br>\n"];
    }
  }

  // error
  if (error) {
    [outputHTML appendFormat:@"<b>error:</b> %@ <br>\n", [error description]];
  }

  // write the response data.  We have links to show formatted and text
  //   versions, but they both show it in the same iframe, and both
  //   links also toggle visible/hidden
  if (responseDataFormattedFileName || responseDataUnformattedFileName) {

    // response data, toggleable links -- formatted and text versions
    if (responseDataFormattedFileName) {
      [outputHTML appendFormat:@"response data (%d bytes) formatted <b>%@</b> ",
        (int)responseDataLength,
        [responseDataFormattedFileName pathExtension]];

      // inline (iframe) link
      NSString *responseInlineFormattedDataNameFormat = @"&nbsp;&nbsp;<a "
        "href=\"javascript:toggleIFrame('%@','%@','%@');\">inline</a>\n";
      [outputHTML appendFormat:responseInlineFormattedDataNameFormat,
        responseDataDivName, // div ID
        dataIFrameID, // iframe ID (for reloading)
        responseDataFormattedFileName]; // src to reload

      // plain link (so the user can command-click it into another tab)
      [outputHTML appendFormat:@"&nbsp;&nbsp;<a href=\"%@\">stand-alone</a><br>\n",
        [responseDataFormattedFileName
          stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    if (responseDataUnformattedFileName) {
      [outputHTML appendFormat:@"response data (%d bytes) plain text ",
        (int)responseDataLength];

      // inline (iframe) link
      NSString *responseInlineDataNameFormat = @"&nbsp;&nbsp;<a href=\""
        "javascript:toggleIFrame('%@','%@','%@');\">inline</a> \n";
      [outputHTML appendFormat:responseInlineDataNameFormat,
        responseDataDivName, // div ID
        dataIFrameID, // iframe ID (for reloading)
        responseDataUnformattedFileName]; // src to reload

      // plain link (so the user can command-click it into another tab)
      [outputHTML appendFormat:@"&nbsp;&nbsp;<a href=\"%@\">stand-alone</a><br>\n",
        [responseDataUnformattedFileName
          stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }

    // make the iframe
    NSString *divHTMLFormat = @"<div id=\"%@\">%@</div><br>\n";
    NSString *src = responseDataFormattedFileName ?
      responseDataFormattedFileName : responseDataUnformattedFileName;
    NSString *escapedSrc = [src stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *iframeFmt = @" <iframe src=\"%@\" id=\"%@\" width=800 height=400>"
      "\n<a href=\"%@\">%@</a>\n </iframe>\n";
    NSString *dataIFrameHTML = [NSString stringWithFormat:iframeFmt,
      escapedSrc, dataIFrameID, escapedSrc, src];
    [outputHTML appendFormat:divHTMLFormat,
      responseDataDivName, dataIFrameHTML];
  } else {
    // could not parse response data; just show the length of it
    [outputHTML appendFormat:@"<i>Response data: %d bytes </i>\n",
      (int) responseDataLength];
  }

  // make a single string of the request and response, suitable for copying
  // to the clipboard and pasting into a bug report
  NSMutableString *copyable = [NSMutableString string];
  if (comment) {
    [copyable appendFormat:@"%@\n\n", comment];
  }
  [copyable appendFormat:@"%@\n", [NSDate date]];
  [copyable appendFormat:@"Request: %@ %@\n", requestMethod, requestURL];
  [copyable appendFormat:@"Request headers:\n%@\n",
   [[self class] headersStringForDictionary:requestHeaders
                                alignColons:NO]];

  if (postDataLength > 0) {
    [copyable appendFormat:@"Request body: (%u bytes)\n",
     (unsigned int) postDataLength];
    if (postDataStr) {
      [copyable appendFormat:@"%@\n\n", postDataStr];
    }
  }

  if (response) {
    [copyable appendFormat:@"Response: status %d\n", (int) status];
    [copyable appendFormat:@"Response headers:\n%@\n",
     [[self class] headersStringForDictionary:responseHeaders
                                  alignColons:NO]];
    [copyable appendFormat:@"Response body: (%u bytes)\n",
     (unsigned int) responseDataLength];
    if (responseDataLength > 0) {
      [copyable appendFormat:@"%@\n", responseDataStr];
    }
  }

  if (error) {
    [copyable appendFormat:@"Error: %@\n", error];
  }

  // save to log property before adding the separator
  self.log = copyable;

  [copyable appendString:@"-----------------------------------------------------------\n"];


  // write the copyable version to another file (linked to at the top of the
  // html file, above)
  //
  // ideally, something to just copy this to the clipboard like
  //   <span onCopy='window.event.clipboardData.setData(\"Text\",
  //   \"copyable stuff\");return false;'>Copy here.</span>"
  // would work everywhere, but it only works in Safari as of 8/2010
  if (gIsLoggingToFile) {
    NSString *copyablePath = [logDirectory stringByAppendingPathComponent:copyableFileName];
    NSError *copyableError = nil;
    if (![copyable writeToFile:copyablePath
                    atomically:NO
                      encoding:NSUTF8StringEncoding
                         error:&copyableError]) {
      // error writing to file
      NSLog(@"%@ logging write error:%@ (%@)",
            [self class], copyableError, copyablePath);
    }

    [outputHTML appendString:@"<br><hr><p>"];

    // append the HTML to the main output file
    const char* htmlBytes = [outputHTML UTF8String];
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:htmlPath
                                                               append:YES];
    [stream open];
    [stream write:(const uint8_t *) htmlBytes maxLength:strlen(htmlBytes)];
    [stream close];

    // make a symlink to the latest html
    NSString *symlinkName = [NSString stringWithFormat:@"%@_log_newest.html",
                             processName];
    NSString *symlinkPath = [parentDir stringByAppendingPathComponent:symlinkName];

    [[self class] removeItemAtPath:symlinkPath];
    [[self class] createSymbolicLinkAtPath:symlinkPath
                       withDestinationPath:htmlPath];
  }
}

- (BOOL)logCapturePostStream {
  // This is called when beginning a fetch.  The caller should have already
  // verified that logging is enabled, and should have allocated
  // loggedStreamData_ as a mutable object.

  // if the class GTMProgressMonitorInputStream is not available, bail now
  Class monitorClass = NSClassFromString(@"GTMProgressMonitorInputStream");
  if (!monitorClass) return NO;

  // If we're logging, we need to wrap the upload stream with our monitor
  // stream that will call us back with the bytes being read from the stream

  // our wrapper will retain the old post stream
  [postStream_ autorelease];

  postStream_ = [monitorClass inputStreamWithStream:postStream_
                                             length:0];
  [postStream_ retain];

  [(GTMProgressMonitorInputStream *)postStream_ setMonitorDelegate:self];
  [(GTMProgressMonitorInputStream *)postStream_ setRunLoopModes:[self runLoopModes]];

  SEL readSel = @selector(inputStream:readIntoBuffer:length:);
  [(GTMProgressMonitorInputStream *)postStream_ setReadSelector:readSel];

  // we don't really want monitoring callbacks
  [(GTMProgressMonitorInputStream *)postStream_ setMonitorSelector:NULL];
  return YES;
}

- (void)inputStream:(GTMProgressMonitorInputStream *)stream
     readIntoBuffer:(void *)buffer
             length:(unsigned long long)length {
  // append the captured data
  [loggedStreamData_ appendBytes:buffer length:length];
}

#pragma mark Internal file routines

// we implement plain Unix versions of NSFileManager methods to avoid
// NSFileManager's issues with being used from multiple threads

+ (BOOL)fileOrDirExistsAtPath:(NSString *)path {
  struct stat buffer;
  int result = stat([path fileSystemRepresentation], &buffer);
  return (result == 0);
}

+ (BOOL)makeDirectoryUpToPath:(NSString *)path {
  int result = 0;

  // recursively create the parent directory of the requested path
  NSString *parent = [path stringByDeletingLastPathComponent];
  if (![self fileOrDirExistsAtPath:parent]) {
    result = [self makeDirectoryUpToPath:parent];
  }

  // make the leaf directory
  if (result == 0 && ![self fileOrDirExistsAtPath:path]) {
    result = mkdir([path fileSystemRepresentation], S_IRWXU); // RWX for owner
  }
  return (result == 0);
}

+ (BOOL)removeItemAtPath:(NSString *)path {
  int result = unlink([path fileSystemRepresentation]);
  return (result == 0);
}

+ (BOOL)createSymbolicLinkAtPath:(NSString *)newPath
             withDestinationPath:(NSString *)targetPath {
  int result = symlink([targetPath fileSystemRepresentation],
                       [newPath fileSystemRepresentation]);
  return (result == 0);
}

#pragma mark Formatting utilities

+ (NSString *)snipSubtringOfString:(NSString *)originalStr
                betweenStartString:(NSString *)startStr
                         endString:(NSString *)endStr {

  if (originalStr == nil) return nil;

  // find the start string, and replace everything between it
  // and the end string (or the end of the original string) with "_snip_"
  NSRange startRange = [originalStr rangeOfString:startStr];
  if (startRange.location == NSNotFound) return originalStr;

  // we found the start string
  NSUInteger originalLength = [originalStr length];
  NSUInteger startOfTarget = NSMaxRange(startRange);
  NSRange targetAndRest = NSMakeRange(startOfTarget,
                                      originalLength - startOfTarget);
  NSRange endRange = [originalStr rangeOfString:endStr
                                        options:0
                                          range:targetAndRest];
  NSRange replaceRange;
  if (endRange.location == NSNotFound) {
    // found no end marker so replace to end of string
    replaceRange = targetAndRest;
  } else {
    // replace up to the endStr
    replaceRange = NSMakeRange(startOfTarget,
                               endRange.location - startOfTarget);
  }

  NSString *result = [originalStr stringByReplacingCharactersInRange:replaceRange
                                                          withString:@"_snip_"];
  return result;
}

+ (NSString *)headersStringForDictionary:(NSDictionary *)dict
                             alignColons:(BOOL)shouldAlignColons {
  // format the dictionary in http header style, like
  //   Accept:        application/json
  //   Cache-Control: no-cache
  //   Content-Type:  application/json; charset=utf-8
  //
  // pad the key names, but not beyond 16 chars, since long custom header
  // keys just create too much whitespace
  NSArray *keys = [[dict allKeys] sortedArrayUsingSelector:@selector(compare:)];
  NSNumber *maxKeyNum = [keys valueForKeyPath:@"@max.length"];
  NSUInteger maxKeyLen = [maxKeyNum unsignedIntValue];

  NSMutableString *str = [NSMutableString string];
  for (NSString *key in keys) {
    NSString *value = [dict valueForKey:key];
    if ([key isEqual:@"Authorization"]) {
      // remove OAuth 1 token
      value = [[self class] snipSubtringOfString:value
                              betweenStartString:@"oauth_token=\""
                                       endString:@"\""];

      // remove OAuth 2 bearer token (draft 16, and older form)
      value = [[self class] snipSubtringOfString:value
                              betweenStartString:@"Bearer "
                                       endString:@"\n"];
      value = [[self class] snipSubtringOfString:value
                              betweenStartString:@"OAuth "
                                       endString:@"\n"];
    }
    if (shouldAlignColons) {
      [str appendFormat:@"%*s: %@\n", maxKeyLen, [key UTF8String], value];
    } else {
      [str appendFormat:@"  %@: %@\n", key, value];
    }
  }
  return str;
}

+ (id)JSONObjectWithData:(NSData *)data {
  Class serializer = NSClassFromString(@"NSJSONSerialization");
  if (serializer) {
    const NSUInteger kOpts = (1UL << 0); // NSJSONReadingMutableContainers
    NSMutableDictionary *obj;
    obj = [serializer JSONObjectWithData:data
                                 options:kOpts
                                   error:NULL];
    return obj;
  } else {
    // try SBJsonParser or SBJSON
    Class jsonParseClass = NSClassFromString(@"SBJsonParser");
    if (!jsonParseClass) {
      jsonParseClass = NSClassFromString(@"SBJSON");
    }
    if (jsonParseClass) {
      GTMFetcherSBJSON *parser = [[[jsonParseClass alloc] init] autorelease];
      NSString *jsonStr = [[[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding] autorelease];
      if (jsonStr) {
        NSMutableDictionary *obj = [parser objectWithString:jsonStr error:NULL];
        return obj;
      }
    }
  }
  return nil;
}

+ (id)stringWithJSONObject:(id)obj {
  Class serializer = NSClassFromString(@"NSJSONSerialization");
  if (serializer) {
    const NSUInteger kOpts = (1UL << 0); // NSJSONWritingPrettyPrinted
    NSData *data;
    data = [serializer dataWithJSONObject:obj
                                  options:kOpts
                                    error:NULL];
    if (data) {
      NSString *jsonStr = [[[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding] autorelease];
      return jsonStr;
    }
  } else {
    // try SBJsonParser or SBJSON
    Class jsonWriterClass = NSClassFromString(@"SBJsonWriter");
    if (!jsonWriterClass) {
      jsonWriterClass = NSClassFromString(@"SBJSON");
    }
    if (jsonWriterClass) {
      GTMFetcherSBJSON *writer = [[[jsonWriterClass alloc] init] autorelease];
      [writer setHumanReadable:YES];
      NSString *jsonStr = [writer stringWithObject:obj error:NULL];
      return jsonStr;
    }
  }
  return nil;
}

@end

#endif // !STRIP_GTM_FETCH_LOGGING
