//
//  StationsTVC.h
//  DWMB
//
//  Created by Pete Hodgson on 7/6/11.
//  Copyright 2011 Pete Hodgson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StationsTVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UITextFieldDelegate> {
	NSArray *_stations;
	NSArray *_filteredStations;
	
	UITableView *_tableView;
	UISearchBar *_searchBar;
}
@property(retain) NSArray *_filteredStations;
@property(nonatomic,retain) UITableView *tableView;
@property(nonatomic,retain) UISearchBar *searchBar;

@end
