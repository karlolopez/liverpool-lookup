//
//  Product.m
//  Liverpool LookUp
//
//  Created by Karlo A. López on 21/09/20.
//  Copyright © 2020 Karlo A. López. All rights reserved.
//

#import "Product.h"

@implementation Product

@synthesize productDisplayName;
@synthesize lgImage;
@synthesize listPrice;
@synthesize listPriceDisplay;

-(id)init {
   self = [super init];
    self.productDisplayName = @"Producto";
    self.lgImage = @"";
    self.listPriceDisplay = @"$ - ";
    self.listPrice = (float)0;
   return self;
}

-(void) setProductData: (NSDictionary *)data{
    if([data objectForKey:@"lgImage"]){
        self.lgImage = [data objectForKey:@"lgImage"];
    }
    if([data objectForKey:@"productDisplayName"]){
        self.productDisplayName = [data objectForKey:@"productDisplayName"];
    }
    if([data objectForKey:@"listPrice"]){
        
        self.listPrice = [[data objectForKey:@"listPrice"] floatValue];
        self.listPriceDisplay = [NSString stringWithFormat:@"$%.02f", self.listPrice];
        
    }
}

@end
