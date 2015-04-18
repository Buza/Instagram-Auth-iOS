//
//  InstagramAuthController.m
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

#import "InstagramAuthController.h"

#import "InstagramAuthenticatorView.h"

#import "SizerView.h"

@interface InstagramAuthController ()

@end

@implementation InstagramAuthController

@synthesize completionBlock;
@synthesize authDelegate;

- (id)init
{
    self = [super init];
    if (self)
    {
        //We use a special view that will tell us what the proper frame size is so we can
        //make sure the login view is centered in the modal view controller.
        self.view = [[SizerView alloc] initWithFrame:CGRectZero frameChangeDelegate:self];
        self.authDelegate = nil;
    }
    return self;
}

-(void) dealloc
{
}

-(void) didAuthWithToken:(NSString*)token
{
    [self.authDelegate didAuthWithToken:token];
    self.completionBlock();
}

-(void) frameChanged:(CGRect)frame
{
    InstagramAuthenticatorView *gha = [[InstagramAuthenticatorView alloc] initWithFrame:frame];
    gha.authDelegate = self;
    [self.view addSubview:gha];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


@end
