//
//  Product.h
//  Liverpool LookUp
//
//  Created by Karlo A. López on 21/09/20.
//  Copyright © 2020 Karlo A. López. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Product : NSObject

@property(nonatomic, readwrite) NSString *productDisplayName;
@property(nonatomic, readwrite) NSString *lgImage;
@property(nonatomic, readwrite) float listPrice;
@property(nonatomic, readwrite) NSString *listPriceDisplay;
-(void) setProductData: (NSDictionary *)data;
@end

NS_ASSUME_NONNULL_END
