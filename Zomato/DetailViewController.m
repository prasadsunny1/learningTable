//
//  DetailViewController.m
//  Zomato
//
//  Created by Sanni Prasad on 13/01/17.
//  Copyright © 2017 Sanni Prasad. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UIImageView *immage;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _label.text = _transferedTitle;
    
    dispatch_async(dispatch_queue_create(nil, nil), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_transferdImage]];
        dispatch_async(dispatch_get_main_queue(), ^{
            _immage.image = [UIImage imageWithData:data];
        });
        
    });
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
