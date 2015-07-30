//
//  MediaFeedViewController.m
//  InstaProwler
//
//  Created by Andrey Yashnev on 27/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import "MediaFeedViewController.h"
#import "InstagramMediaItemsModel.h"
#import "Objection.h"
#import "MediaFeedCell.h"
#import "NotificationHandler.h"
#import "Reachability.h"

#import "UIColor+Additions.h"
#import "UIView+Additions.h"
#import "NSError+Additions.h"
#import "UIScrollView+SVInfiniteScrolling.h"

@interface MediaFeedViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *tableHeaderContainer;
@property (nonatomic, weak) IBOutlet UITextField *searchTextField;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIView *statusBarOverlay;
@property (nonatomic, weak) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, weak) IBOutlet UIImageView *offlineImageView;

@property (nonatomic, weak) id<InstagramMediaItemsModel> mediaItemsModel;

@property (nonatomic, strong) NotificationHandler *modelLoadingHandler;
@property (nonatomic, strong) NotificationHandler *itemsChangedhandler;
@property (nonatomic, strong) NSDateFormatter *creationDateFormatter;
@property (nonatomic, strong) Reachability *reachability;

@end

@implementation MediaFeedViewController
objection_register(MediaFeedViewController)
objection_requires(@"mediaItemsModel")


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];
    
    self.offlineImageView.image = [self.offlineImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.offlineImageView.tintColor = [UIColor whiteColor];
    
    self.searchTextField.layer.cornerRadius = self.searchTextField.frame.size.height / 2;
    self.searchTextField.layer.borderWidth = 0.5;
    self.searchTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.tableHeaderContainer.backgroundColor =
    self.statusBarOverlay.backgroundColor = [UIColor ip_applicationMainColor];
    
    self.tableView.tableHeaderView = self.tableHeaderContainer;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.creationDateFormatter = [[NSDateFormatter alloc] init];
    [self.creationDateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    NSString *cellClassName = NSStringFromClass([MediaFeedCell class]);
    [self.tableView registerNib:[UINib nibWithNibName:cellClassName bundle:nil]
         forCellReuseIdentifier:cellClassName];
    
    __weak typeof(self) wself = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [wself.mediaItemsModel loadNextPage];
    }];
    self.tableView.infiniteScrollingView.enabled = NO;
    
    self.modelLoadingHandler = [NotificationHandler handlerWithBlock:^(NSNotification *notification) {
        if (wself.mediaItemsModel.state != InstagramMediaItemsModelStateProgress) {
            [wself setProgressEnabled:NO];
        } else {
            [wself setProgressEnabled:YES];
        }
    } forNotification:kInstagramMediaItemsModelStateChangedNotification fromObject:nil];
    self.itemsChangedhandler = [NotificationHandler handlerWithBlock:^(NSNotification *notification) {
       [wself.tableView reloadData];
        wself.tableView.infiniteScrollingView.enabled = [wself.mediaItemsModel hasMoreItems];
    } forNotification:kInstagramMediaItemsModelChangedNotification fromObject:nil];
    self.searchTextField.tintColor = [UIColor whiteColor];
    
    
    self.reachability = [Reachability reachabilityForInternetConnection];
    if (![self.reachability isReachable]) {
        self.offlineImageView.alpha = 1;
    }
    
    self.reachability.reachableBlock = ^void(Reachability *reach) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                wself.offlineImageView.alpha = 0;
                wself.tableView.infiniteScrollingView.enabled = [wself.mediaItemsModel hasMoreItems];
            }];
        });
    };
    self.reachability.unreachableBlock = ^void(Reachability *reach) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                wself.offlineImageView.alpha = 1;
                wself.tableView.infiniteScrollingView.enabled = NO;
            }];
        });
    };
    [self.reachability startNotifier];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self.searchTextField becomeFirstResponder];
}

#pragma mark - Private

- (void)setProgressEnabled:(BOOL)enabled {
    if (enabled) {
        if ([[self.mediaItemsModel mediaItems] count] > 0) {
            [self.tableView.infiniteScrollingView startAnimating];
        } else {
            [self.activityIndicator startAnimating];
            [UIView animateWithDuration:0.15 animations:^{
                self.placeholderLabel.alpha = 0;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.15 animations:^{
                    self.activityIndicator.alpha = 1;
                }];
            }];
        }
    } else {
        [self.tableView.infiniteScrollingView stopAnimating];
        [self.activityIndicator stopAnimating];
        [UIView animateWithDuration:0.15 animations:^{
            self.activityIndicator.alpha = 0;
        } completion:^(BOOL finished) {
            [self.activityIndicator stopAnimating];
            if ([[self.mediaItemsModel mediaItems] count] == 0) {
                if ([self.mediaItemsModel lastError] == nil) {
                    self.placeholderLabel.text = @"Enter username to search and view his feed";
                } else {
                    NSError *error = [self.mediaItemsModel lastError];
                    if (error.code == kInstagramMediaItemsModelNoSuchUser) {
                        self.placeholderLabel.text = @"User not found";
                    } else if (error.code == kInstagramServiceAccountIsPrivate) {
                        self.placeholderLabel.text = @"User account is private";
                    } else {
                        self.placeholderLabel.text = @"Error occured";
                    }
                }
                
                [UIView animateWithDuration:0.3 animations:^{
                    self.placeholderLabel.alpha = 1;
                }];
            }
        }];
    }
}

- (void)searchWithCurrentText {
    [self.mediaItemsModel loadNextPageForSearchString:self.searchTextField.text];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.searchTextField resignFirstResponder];
    [self searchWithCurrentText];
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.mediaItemsModel mediaItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellClassName = NSStringFromClass([MediaFeedCell class]);
    MediaFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:cellClassName];
    cell.dateFormatter = self.creationDateFormatter;
    cell.mediaItem = [self.mediaItemsModel mediaItems][indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        scrollView.contentOffset = CGPointZero;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MediaFeedCell heightWithItem:[self.mediaItemsModel mediaItems][indexPath.row]];
}


@end
