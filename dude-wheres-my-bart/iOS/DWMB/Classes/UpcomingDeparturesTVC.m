//
//  UpcomingDeparturesTVC.m
//  DWMB
//
//  Created by Pete Hodgson on 7/6/11.
//  Copyright 2011 Pete Hodgson. All rights reserved.
//

#import "UpcomingDeparturesTVC.h"


@implementation UpcomingDeparturesTVC

- (void) setSubjectStation:(Station *)station{
	[_subjectStation release];
	_subjectStation = [station retain];
	self.title = _subjectStation.name;
}

#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[_departures release];
	_departures = nil;
	[_subjectStation requestUpcomingDepartures:^(NSArray *departures){
		[_departures release];
		_departures = [departures retain];
		[[self tableView] reloadData];
	}];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if( !_departures )
		return 1;
	else
		return [_departures count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.font = [UIFont systemFontOfSize:20.0];
		cell.detailTextLabel.font = [UIFont systemFontOfSize:30.0];
		cell.detailTextLabel.lineBreakMode = UILineBreakModeClip;
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    }
	
	if( !_departures )
	{
		cell.textLabel.text = @"Loading...";
		return cell;
	}
    
    NSDictionary *departureDict = [_departures objectAtIndex:indexPath.row];
	NSNumber *etdInMinutes = [departureDict objectForKey:@"etd"];
	NSString *destName = [departureDict objectForKey:@"dest_name"];
	NSString *route = [departureDict objectForKey:@"route"];
	
	cell.textLabel.text = destName;
	if( [etdInMinutes intValue] != 0 )
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ min", etdInMinutes];
	else
		cell.detailTextLabel.text = @"now";

	// ACK!
//	if( [route isEqualToString:@"YELLOW"] )
//		[cell.contentView setBackgroundColor:[UIColor yellowColor]];
//	else if( [route isEqualToString:@"BLUE"] )
//		 [cell.contentView setBackgroundColor:[UIColor blueColor]];
//	else if( [route isEqualToString:@"ORANGE"] )
//		[cell.contentView setBackgroundColor:[UIColor orangeColor]];
//	else if( [route isEqualToString:@"RED"] )
//		[cell.contentView setBackgroundColor:[UIColor redColor]];
//	else if( [route isEqualToString:@"GREEN"] )
//		 [cell.contentView setBackgroundColor:[UIColor greenColor]];
	
		 

	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

