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

#pragma mark - Actions

- (IBAction)searchAction:(id)sender {
    [self.instaService searchForUserWithString:self.searchField.text successBlock:^(NSArray *users) {
        NSLog(@"%@", users);
    } errorBlock:^(NSError *error) {
        
    }];
}

@end
