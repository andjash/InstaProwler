//
//  SearchViewController.m
//  InstaProwler
//
//  Created by Andrey Yashnev on 24/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import "SearchViewController.h"
#import "Objection.h"
#import "InstagramService.h"
#import "InstagramUser.h"

@interface SearchViewController ()

@property (nonatomic, strong) id<InstagramService> instaService;

@property (nonatomic, weak) IBOutlet UITextField *searchField;

@end

@implementation SearchViewController
objection_register(SearchViewController)
objection_requires(@"instaService")

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - Private

- (void)getUsersRecentMedia:(InstagramUser *)user {
    [self.instaService recentMediaForUserWithId:user.userId count:@(5) minId:@(0) successBlock:^(NSArray *result) {
        NSLog(@"%@", result);
    } errorBlock:^(NSError *error) {
        
    }];
}

#pragma mark - Actions

- (IBAction)searchAction:(id)sender {
    [self.instaService searchForUserWithString:self.searchField.text successBlock:^(NSArray *users) {
        InstagramUser *requiredUser = nil;
        for (InstagramUser *user in users) {
            if ([self.searchField.text isEqualToString:user.username]) {
                requiredUser = user;
                break;
            }
        }
        if (requiredUser) {
            [self getUsersRecentMedia:requiredUser];
        }
    } errorBlock:^(NSError *error) {
        
    }];
}

@end
