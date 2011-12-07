//
//  StationsTVC.m
//  DWMB
//
//  Created by Pete Hodgson on 7/6/11.
//  Copyright 2011 Pete Hodgson. All rights reserved.
//

#import "StationsTVC.h"

#import "DWMBAppDelegate.h"
#import "Station.h"
#import "UpcomingDeparturesTVC.h"


@implementation StationsTVC
@synthesize tableView=_tableView,searchBar=_searchBar,_filteredStations;

#pragma mark -
#pragma mark View lifecycle

- (void) loadView {
	self.view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)] autorelease];
	
	self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)]autorelease];
	[self.searchBar setTintColor:BART_BLUE];
	[self.searchBar setPlaceholder:@"enter part of a station name"];
	[self.searchBar setDelegate:self];

	for (UIView *subview in self.searchBar.subviews){
		if ([subview isKindOfClass: [UITextField class]]) {
			[(UITextField *)subview setDelegate:self];
			[(UITextField *)subview setReturnKeyType:UIReturnKeyDone];
			[(UITextField *)subview setKeyboardAppearance:UIKeyboardAppearanceAlert];
			break;
		}
	}
	
	[self.view addSubview:self.searchBar];
	
	self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, 480-44)] autorelease];
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	[self.tableView setDelegate:self];
	[self.tableView setDataSource:self];
	[self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
		
	self.title = @"Stations";
	
	[_stations release];
	_stations = [[DWMBAppDelegate allStations] copy];
	self._filteredStations = _stations;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
}

-(void) viewWillDisappear:(BOOL)animated{
	[self.searchBar resignFirstResponder];
}

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_filteredStations count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
	
	Station *selectedStation = [_filteredStations objectAtIndex:indexPath.row];
    cell.textLabel.text = [selectedStation name];
	
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
	Station *selectedStation = [_filteredStations objectAtIndex:indexPath.row];

	UpcomingDeparturesTVC *upcomingDeparturesTVC = [[UpcomingDeparturesTVC alloc] init];
    [upcomingDeparturesTVC setSubjectStation:selectedStation];
	[self.navigationController pushViewController:upcomingDeparturesTVC animated:YES];
	[upcomingDeparturesTVC release];
}

#pragma mark -
#pragma mark UISearchBarDelegate implementation

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
	int length = [[searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length];
	if (length == 0 || searchText == nil)
	{
		[self.searchBar setShowsCancelButton:YES animated:YES];
		self._filteredStations = _stations;
		[self.tableView reloadData];
		return;
	}
	
	[self.searchBar setShowsCancelButton:NO animated:YES];
	
	NSPredicate *sPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
	self._filteredStations = [_stations filteredArrayUsingPredicate:sPredicate];
	[self.tableView reloadData];
}

-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	[self.searchBar setShowsCancelButton:[searchBar.text isEqualToString:@""] animated:YES];
}
-(void) searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	[self.searchBar setShowsCancelButton:NO animated:YES];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar{
	[searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}

#pragma mark -
#pragma mark UITextFieldDelegate implementation

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	if( textField.editing && [textField.text isEqualToString:@""] ){
		//if we only try and resignFirstResponder on textField or searchBar,
		//the keyboard will not dissapear
		[self performSelector:@selector(searchBarCancelButtonClicked:) withObject:self.searchBar afterDelay: 0.1];
	}
	return YES;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	RELEASE_SAFELY(_stations);
	self.tableView = nil;
	self.searchBar = nil;
}


- (void)dealloc {
	RELEASE_SAFELY(_stations);
	self._filteredStations = nil;
	self.tableView = nil;
	self.searchBar = nil;
	
    [super dealloc];
}


@end

