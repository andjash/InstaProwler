//
//  ImageDownloadModel.h
//  InstaProwler
//
//  Created by Andrey Yashnev on 27/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageDownloadProgressTicket.h"

@protocol ImageDownloadModel <NSObject>

- (ImageDownloadProgressTicket *)ticketForUrl:(NSString *)url;
- (ImageDownloadProgressTicket *)downloadImageForUrl:(NSString *)url;

@end
