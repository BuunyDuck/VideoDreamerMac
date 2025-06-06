//
//  MusicDownloadWebVC.m
//  VideoFrame
//
//  Created by APPLE on 11/14/17.
//  Copyright © 2017 Yinjing Li. All rights reserved.
//

#import "MusicDownloadWebVC.h"
#import "MusicDownloadController.h"
#import "SHKActivityIndicator.h"
#import "YJLCustomMusicController.h"
#import "MediaTrimView.h"
#import "NSDate+Extension.h"
#import "FileNetworkManager.h"

@interface MusicDownloadWebVC () <MediaTrimViewDelegate>
{
    IBOutlet UIBarButtonItem *cancelButton;
    
    YJLCustomMusicController *musicPicker;
    
    NSDictionary *responseHeaders;
}

@property (nonatomic, strong) NSString *lastFileName;

@end

@implementation MusicDownloadWebVC

@synthesize musicDownloadController = musicDownloadController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *normalButtonItemAttributes = @{NSFontAttributeName:[UIFont fontWithName:MYRIADPRO size:16.0],
                                                 NSForegroundColorAttributeName:[UIColor blackColor]};
    NSDictionary *highlightButtonItemAttributes = @{NSFontAttributeName:[UIFont fontWithName:MYRIADPRO size:16.0],
                                                    NSForegroundColorAttributeName:[UIColor darkGrayColor]};
    [cancelButton setTitleTextAttributes:normalButtonItemAttributes forState:UIControlStateNormal];
    [cancelButton setTitleTextAttributes:highlightButtonItemAttributes forState:UIControlStateHighlighted];
    
    NSString *javaScript = @"var vids = document.getElementsByTagName(\"video\"); for(var i = 0; i < vids.length; i++) { vids[i].muted = true; vids[i].controls = false; vids[i].pause(); } var auds = document.getElementsByTagName(\"audio\"); for(var i = 0; i < auds.length; i++) { auds[i].muted = true; auds[i].controls = false; auds[i].pause(); }";
    WKUserScript *script = [[WKUserScript alloc] initWithSource:javaScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.allowsInlineMediaPlayback = NO;
    configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    
#if TARGET_OS_MACCATALYST
    if (@available(macCatalyst 14.0, *)) {
        WKWebpagePreferences *preferences = [[WKWebpagePreferences alloc] init];
        preferences.allowsContentJavaScript = YES;
        configuration.defaultWebpagePreferences = preferences;
    }
#else
    WKPreferences *preferences = [[WKPreferences alloc] init];
    preferences.javaScriptEnabled = YES;
    configuration.preferences = preferences;
#endif
    
    [configuration.userContentController addUserScript:script];
    
    self.musicWebView = [[WKWebView alloc] initWithFrame:self.webContainerView.bounds configuration:configuration];
    [self.webContainerView addSubview:self.musicWebView];
    
    self.musicWebView.navigationDelegate = self;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSURL *url = [userDefaults URLForKey:@"viewSite"];
    
    if (url == nil) {
        NSString *urlString = @"https://www.youtube.com/audiolibrary/music";
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.musicWebView loadRequest:request];
    } else {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.musicWebView loadRequest:request];
    }
    
    self.lastFileName = @"";
    self.musicDownloadController = (MusicDownloadController*)self.navigationController;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : @""}];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.musicWebView.frame = self.webContainerView.bounds;
}

- (void)checkDownloadableContent:(NSURLRequest *)request completionHandler:(void(^)(BOOL, NSString *))completionHandler decisionHandler:(void(^)(WKNavigationActionPolicy))decisionHandler {
    NSMutableURLRequest *urlRequest = [request mutableCopy];
    if ([NSHTTPCookieStorage sharedHTTPCookieStorage].cookies != nil) {
        NSArray *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
        for (NSHTTPCookie *cookie in cookies) {
            [urlRequest setValue:cookie.value forHTTPHeaderField:cookie.name];
        }
    }
    for (NSString *key in responseHeaders.allKeys) {
        [urlRequest setValue:responseHeaders[key] forHTTPHeaderField:key];
    }

    urlRequest.HTTPMethod = @"OPTIONS";
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (response != nil && [response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSDictionary *headers = ((NSHTTPURLResponse *)response).allHeaderFields;
            NSString *contentType = headers[@"Content-Type"];
            if (contentType != nil) {
                NSString *filename = response.suggestedFilename;
                filename = [filename stringByReplacingOccurrencesOfString:@"+" withString:@" "];
                if ([contentType isEqualToString:@"application/binary"]) {
                    contentType = [[FileNetworkManager sharedManager] contentType:request.URL];
                } else if (filename != nil && [contentType.lowercaseString isEqualToString:@"text/plain; charset=utf-8"]) {
                    NSURL *url = [NSURL URLWithString:[filename stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
                    contentType = [[FileNetworkManager sharedManager] contentType:url];
                } else if ([filename isEqualToString:@"file"] && ([self.lastFileName containsString:@".mp3"] || [self.lastFileName containsString:@".wav"])) {
                    filename = self.lastFileName;
                    contentType = @"audio/mp3";
                }
                
                self.lastFileName = filename;
                if (data != nil && ([contentType isEqualToString:@"audio/mpeg"] || [contentType isEqualToString:@"audio/mp3"] || [contentType isEqualToString:@"audio/wav"] || [contentType isEqualToString:@"audio/wave"] || [contentType isEqualToString:@"application/binary"])) { // Music
                    if (filename == nil) {
                        filename = @"";
                    }
                    decisionHandler(WKNavigationActionPolicyCancel);
                    completionHandler(YES, filename);
                } else {
                    decisionHandler(WKNavigationActionPolicyAllow);
                    completionHandler(NO, nil);
                }
            } else {
                decisionHandler(WKNavigationActionPolicyAllow);
                completionHandler(NO, nil);
            }
        } else {
            decisionHandler(WKNavigationActionPolicyAllow);
            completionHandler(NO, nil);
        }
    }];

    [dataTask resume];
}

- (void)downloadMusicFile:(NSURLRequest *)request {
    NSURLSessionDataTask* dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
        NSString* contentType = [headers objectForKey:@"Content-Type"];

        if ([contentType isEqualToString:@"audio/mpeg"] && data != nil) // Music
        {
            NSString* toFolderName = @"Music Library";
            NSString *toFolderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
            NSString *toFolderPath = [toFolderDir stringByAppendingPathComponent:toFolderName];
            toFolderPath = [toFolderPath stringByAppendingPathComponent:@"Library"];

            NSFileManager *localFileManager = [NSFileManager defaultManager];

            if (![localFileManager fileExistsAtPath:toFolderPath])
                [localFileManager createDirectoryAtPath:toFolderPath withIntermediateDirectories:YES attributes:nil error:nil];

            NSString* fileName = [response suggestedFilename];

            if (fileName == nil)
            {
                fileName = [[NSDate date] tempMP3FileName];
            }
            
            NSString* filePath = [toFolderPath stringByAppendingPathComponent:fileName];

            [data writeToFile:filePath atomically:YES];

            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController* alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Video Dreamer", nil)
                                                                                         message:NSLocalizedString(@"Music has been downloaded successfully", nil) preferredStyle:UIAlertControllerStyleAlert];

                UIAlertAction *moreAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Download More", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                    NSLog(@"moreAction");
                }];

                UIAlertAction* goAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Go to Library", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

                    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setBool:YES forKey:@"fromDownload"];

                    [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];

                    if ([self.musicDownloadController.musicDownloadControllerDelegate respondsToSelector:@selector(goToLibraryFromMusicDownloadController:)])
                    {
                        [self.musicDownloadController.musicDownloadControllerDelegate goToLibraryFromMusicDownloadController:self.musicDownloadController];
                    }
                }];

                UIAlertAction* importAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Import Song", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];

                    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
                    self.assetUrl = fileUrl;

                    if (([self.musicDownloadController.musicDownloadControllerDelegate respondsToSelector:@selector(importSong:asset:)]) && (self.assetUrl != nil))
                    {
                        [self.musicDownloadController.musicDownloadControllerDelegate importSong:self.musicDownloadController asset:self.assetUrl];
                    }
                    else if (self.assetUrl == nil)
                    {
                        [self showAlertViewController:NSLocalizedString(@"Video Dreamer", nil) message:NSLocalizedString(@"You can`t use this music. Please use this music after download music from the iTunes Store.", nil) okHandler:nil];
                    }
                }];

                [alertController addAction:moreAction];
                [alertController addAction:goAction];
                [alertController addAction:importAction];

                [self presentViewController:alertController animated:YES completion:nil];

                [[SHKActivityIndicator currentIndicator] hide];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[SHKActivityIndicator currentIndicator] hide];
            });
        }
    }];

    [dataTask resume];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL* requestedURL = [navigationAction.request URL];
    if ([requestedURL.absoluteString isEqualToString:@"about:blank"]) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }

    NSString* lastPath = [requestedURL lastPathComponent];
    if ([lastPath isEqualToString:@"videoplayback"]/* || [requestedURL.absoluteString isEqualToString:@"about:blank"]*/)
    {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    if ([requestedURL.absoluteString containsString:@"https://open.spotify.com/album/"] ||
        [requestedURL.absoluteString containsString:@"https://apps.apple.com/app/"] ||
        [requestedURL.absoluteString containsString:@"https://adservice.google.com/"])
    {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Loading...", nil)) isLock:YES];
    });
    
    [self checkDownloadableContent:navigationAction.request completionHandler:^(BOOL success, NSString *filename) {
        if (success) {
            NSURLRequest *request = navigationAction.request;
            [self downloadMusicFile:request];
        }
    } decisionHandler:decisionHandler];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if ([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
        responseHeaders = response.allHeaderFields;
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {

}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SHKActivityIndicator currentIndicator] hide];
    });
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}

- (IBAction)actionCancel:(id)sender
{
    if ([self.musicDownloadController.musicDownloadControllerDelegate respondsToSelector:@selector(musicDownloadControllerDidCancel:)])
    {
        [self.musicDownloadController.musicDownloadControllerDelegate musicDownloadControllerDidCancel:self.musicDownloadController];
    }
}

@end
