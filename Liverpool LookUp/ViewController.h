//
//  ViewController.h
//  Liverpool LookUp
//
//  Created by Karlo A. López on 21/09/20.
//  Copyright © 2020 Karlo A. López. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViewController : UITableViewController
- (IBAction)loadMoreAction:(id)sender;
@property (weak, nonatomic) IBOutlet UISearchBar *inputSearchBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *loadMoreButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

NS_ASSUME_NONNULL_END
