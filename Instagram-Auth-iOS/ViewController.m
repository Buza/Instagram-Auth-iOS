//
//  ViewController.m
//  Instagram-Auth-iOS
//
//  Created by buza on 9/27/12.
//  Copyright (c) 2012 BuzaMoto. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.

#import "ViewController.h"

#import "InstagramAuthController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    if([INSTAGRAM_CLIENT_ID isEqualToString:@"YOUR CLIENT ID"])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"You must specify your Instagram API credentials in Defines.h."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    } else
    {
        [self performSelector:@selector(checkInstagramAuth) withObject:nil afterDelay:2];
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    [super viewDidLoad];
}


//This is our authentication delegate. When the user logs in, and Instagram sends us our auth token, we receive that here.
-(void) didAuth:(NSString*)token
{
    if(!token)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Failed to request token."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    //As a test, we'll request a list of popular Instagram photos.
    NSString *popularURLString = [NSString stringWithFormat:@"https://api.instagram.com/v1/media/popular?access_token=%@", token];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:popularURLString]];
    
    NSOperationQueue *theQ = [NSOperationQueue new];
    [NSURLConnection sendAsynchronousRequest:request queue:theQ
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               
                               NSError *err;
                               id val = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
                               
                               if(!err && !error && val && [NSJSONSerialization isValidJSONObject:val])
                               {
                                   NSArray *data = [val objectForKey:@"data"];
                                   
                                   dispatch_sync(dispatch_get_main_queue(), ^{
                                       
                                       if(!data)
                                       {
                                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Failed to request perform request."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                           [alertView show];
                                       } else
                                       {
      
                                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"Successfully retrieved popular photos!"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                               [alertView show];
                                          
                                       }
                                    });
                               }
                           }];
}

-(void) checkInstagramAuth
{
    InstagramAuthController *instagramAuthController = [[InstagramAuthController alloc] init];
    instagramAuthController.authDelegate = self;
    
    instagramAuthController.modalPresentationStyle = UIModalPresentationFormSheet;
    instagramAuthController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentViewController:instagramAuthController animated:YES completion:^{ } ];
    
    __weak __block InstagramAuthController *weakAuthController = instagramAuthController;
    
    instagramAuthController.completionBlock = ^(void) {
        [weakAuthController dismissViewControllerAnimated:YES completion:nil];
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
