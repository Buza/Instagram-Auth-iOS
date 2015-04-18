//
//  InstagramAuthenticatorView.m
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

#import "InstagramAuthenticatorView.h"
#import "InstagramAuthDelegate.h"
#import "NSDictionary+UrlEncoding.h"

@interface InstagramAuthenticatorView()
@property(nonatomic, strong) NSMutableData *data;
@property(nonatomic, strong) NSURLConnection *tokenRequestConnection;
@end

@implementation InstagramAuthenticatorView

@synthesize data;
@synthesize authDelegate;
@synthesize tokenRequestConnection;

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        self.delegate = self;
        self.authDelegate = nil;
        self.tokenRequestConnection = nil;
        self.data = [NSMutableData data];
        self.scalesPageToFit = YES;
        [self authorize];
    }
    
    return self;
}

-(void) dealloc
{
    [tokenRequestConnection cancel];
    self.delegate = nil;
}

-(void) authorize
{
    //See http://instagram.com/developer/authentication/ for more details.

    NSString *scopeStr = @"scope=likes+comments+relationships";
    
    NSString *url = [NSString stringWithFormat:@"https://api.instagram.com/oauth/authorize/?client_id=%@&display=touch&%@&redirect_uri=http://buza.mitplw.com&response_type=code", INSTAGRAM_CLIENT_ID, scopeStr];
    
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[self stopLoading];
	
	if([error code] == -1009)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot open the page because it is not connected to the Internet." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *responseURL = [request.URL absoluteString];
    
    NSString *urlCallbackPrefix = [NSString stringWithFormat:@"%@/?code=", INSTAGRAM_CALLBACK_BASE];
    
    //We received the code, now request the auth token from Instagram.
    if([responseURL hasPrefix:urlCallbackPrefix])
    {
        NSString *authToken = [responseURL substringFromIndex:[urlCallbackPrefix length]];

        NSURL *url = [NSURL URLWithString:@"https://api.instagram.com/oauth/access_token"];

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        
        NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:authToken, @"code", INSTAGRAM_CALLBACK_BASE, @"redirect_uri", @"authorization_code", @"grant_type",  INSTAGRAM_CLIENT_ID, @"client_id",  INSTAGRAM_CLIENT_SECRET, @"client_secret", nil];
        
        NSString *paramString = [paramDict urlEncodedString];
        
        NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        
        [request setHTTPMethod:@"POST"];
        [request addValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@",charset] forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding]];
        
        self.tokenRequestConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        [self.tokenRequestConnection start];
        
        return NO;
    }
    
	return YES;
}

#pragma Mark NSURLConnection delegates

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)_data
{
    [self.data appendData:_data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.data setLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *jsonError = nil;
    id jsonData = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&jsonError];
    if(jsonData && [NSJSONSerialization isValidJSONObject:jsonData])
    {
        NSString *accesstoken = [jsonData objectForKey:@"access_token"];
        if(accesstoken)
        {
            [self.authDelegate didAuthWithToken:accesstoken];
            return;
        }
    }

    [self.authDelegate didAuthWithToken:nil];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    return request;
}



@end
