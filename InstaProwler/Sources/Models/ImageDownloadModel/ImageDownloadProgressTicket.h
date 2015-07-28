//
//  ImageDownloadProgressTicket.h
//  InstaProwler
//
//  Created by Andrey Yashnev on 27/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageDownloadProgressTicket : NSObject

@property (nonatomic, assign) float progress;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSDate *dateCreated;

@end
