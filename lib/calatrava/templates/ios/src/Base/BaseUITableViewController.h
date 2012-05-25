#import <UIKit/UIKit.h>
#import "BaseUIViewController.h"

@interface BaseUITableViewController : BaseUIViewController<UITableViewDataSource, UITableViewDelegate>{
    IBOutlet UITableView *tableView;
}
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
