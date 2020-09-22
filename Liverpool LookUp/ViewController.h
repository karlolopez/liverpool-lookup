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

@end

NS_ASSUME_NONNULL_END
