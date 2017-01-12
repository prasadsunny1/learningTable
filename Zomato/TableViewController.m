//
//  TableViewController.m
//  Zomato
//
//  Created by Sanni Prasad on 09/01/17.
//  Copyright © 2017 Sanni Prasad. All rights reserved.
//

#import "TableViewController.h"
#import "TableViewCell.h"
#import "DetailViewController.h"

@interface TableViewController ()
{
    NSURL *urlZomato;
//    restModel *rest1;
    NSMutableArray *arrRestData,*searchResults;
    NSURLSessionDataTask *dataTask;
}




@end

//@implementation restModel
//
//-(instancetype)makeRestorentWithTitle:(NSString * )a image:(UIImage *)b{
//    _title = a;
//    _image=b;
//    return self;
//}
//-(NSString *)description{
//    return [NSString stringWithFormat:@"name %@ image %@",_title,_image];
//}

//@end



@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    rest1 = [restModel new];
//    [rest1 makeRestorentWithTitle:@"not Availible" image:[UIImage new]];
//    NSLog(@"%@",rest1);
    
    arrRestData = nil;
    
    self.refreshControl =[[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor =[UIColor redColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(refreshtable) forControlEvents:UIControlEventValueChanged];
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSDictionary *headers = @{ @"user-key": @"68bf31d1002c0afd201e275fdc33da8b",
                               @"cache-control": @"no-cache",
                               @"postman-token": @"e8b3b578-807b-bd15-7281-ef457efcab11" };
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://developers.zomato.com/api/v2.1/geocode?lat=23.0225&lon=72.5714"]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"%@", error);
                                                    } else {
                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                        NSLog(@"%@", httpResponse);
                                                        NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                                        NSLog(@"%@",responseDict[@"nearby_restaurants"][1][@"restaurant"][@"name"]);
                                                        arrRestData = [NSMutableArray arrayWithArray:responseDict[@"nearby_restaurants"]];
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [arrRestData sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"restaurant.name" ascending:false]]];

                                                            [self.tableView reloadData];
                                                            [self.refreshControl endRefreshing];
                                                        });
                                                    }
                                                }];
//    [dataTask resume];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"restaurant.name contains[cd] %@",
                                    searchText];
    
    searchResults = [arrRestData filteredArrayUsingPredicate:resultPredicate].mutableCopy;
    NSLog(@"search results %@",searchResults);
}


-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"detail"]) {
        DetailViewController *detailObject = (DetailViewController*)[segue destinationViewController];
        detailObject.transferdImage = arrRestData[[self.tableView indexPathForSelectedRow].row][@"restaurant"][@"thumb"];
        detailObject.transferedTitle = arrRestData[[self.tableView indexPathForSelectedRow].row][@"restaurant"][@"name"];
    }
}

-(void)refreshtable{
    
    
    [dataTask resume];
    
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
    }
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    if (arrRestData) {
        return 1;
        
    }
    else{
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];

        [messageLabel setText:@"no data pull to refresh"];
        messageLabel.textAlignment = NSTextAlignmentCenter;

        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (arrRestData) {
        
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            return [searchResults count];
            
        } else {
            return [arrRestData count];
            
        }
    }
    else
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = (TableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    
    
    
    if (arrRestData) {
        
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            cell.textLabel.text = searchResults[indexPath.row][@"restaurant"][@"name"];
        } else {
            cell.lblTitle.text = arrRestData[indexPath.row][@"restaurant"][@"name"];
            dispatch_async(dispatch_queue_create(nil, nil), ^{
                NSData *tempData = [NSData dataWithContentsOfURL:[NSURL URLWithString:arrRestData[indexPath.row][@"restaurant"][@"thumb"]] options:NSDataReadingMappedIfSafe error:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.imgRest.image = [UIImage imageWithData:tempData];
                });
            });

        }
        
    }
    
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
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
