//
//  TableViewCell.h
//  Zomato
//
//  Created by Sanni Prasad on 10/01/17.
//  Copyright © 2017 Sanni Prasad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgRest;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblCusine;
@property (strong, nonatomic) IBOutlet UILabel *lbladdress;

@end
