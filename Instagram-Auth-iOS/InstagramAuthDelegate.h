//
//  InstagramAuthDelegate.h
//  Instagram-Auth-iOS
//
//  Created by buza on 4/17/15.
//  Copyright (c) 2015 buza. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol InstagramAuthDelegate <NSObject>

-(void) didAuthWithToken:(NSString*)token;

@end
