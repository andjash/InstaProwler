//
//  MediaFeedCell.m
//  InstaProwler
//
//  Created by Andrey Yashnev on 27/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import "MediaFeedCell.h"
#import "InstagramMediaItem.h"
#import "InstagramUser.h"
#import "ImageDownloadModel.h"
#import "Objection.h"
#import "UAProgressView.h"

#import "UIView+Additions.h"
#import "UIColor+Additions.h"

@interface MediaFeedCell ()

@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UILabel *creationDateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *photoImageView;
@property (nonatomic, weak) IBOutlet UILabel *commentsLabel;
@property (nonatomic, weak) IBOutlet UILabel *progressLabel;
@property (nonatomic, weak) IBOutlet UAProgressView *progressView;
@property (nonatomic, strong) ImageDownloadProgressTicket *imageTicket;

@end


@implementation MediaFeedCell

#pragma mark - Static

+ (CGFloat)heightWithItem:(InstagramMediaItem *)item {
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 10;
    CGRect paragraphRect =
    [[self attributedStringFromComments:item.comments] boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                                    options:(NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading)
                                                                    context:nil];
    return paragraphRect.size.height + [UIScreen mainScreen].bounds.size.width + 23;
}

+ (NSAttributedString *)attributedStringFromComments:(NSArray *)comments {
    UIFont *authorFont = [UIFont boldSystemFontOfSize:14];
    UIFont *commentFont = [UIFont systemFontOfSize:14];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
    
    for (InstagramMediaItemComment *itemComment in comments) {
        NSString *authorString = [NSString stringWithFormat:@"%@ ", itemComment.author.username];
        NSAttributedString *commentAuthorString = [[NSAttributedString alloc] initWithString:authorString attributes:    @{NSFontAttributeName : authorFont,                                                                                                                                     NSForegroundColorAttributeName : [UIColor ip_applicationMainColor]}];
        
        NSAttributedString *commentString = [[NSAttributedString alloc] initWithString:itemComment.text attributes:
                                             @{NSFontAttributeName : commentFont,
                                               NSForegroundColorAttributeName : [UIColor darkGrayColor]}];
        NSAttributedString *lineBreak = [[NSAttributedString alloc] initWithString:@"\n"];
        
        
        [attrString appendAttributedString:commentAuthorString];
        [attrString appendAttributedString:commentString];
        [attrString appendAttributedString:lineBreak];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineSpacing = 3;
        [attrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attrString.length)];
    }
    return attrString;
}

#pragma mark - NSObject

- (void)dealloc {
    if (self.imageTicket) {
        [self.imageTicket removeObserver:self forKeyPath:@"progress"];
    }
}

#pragma mark - UIView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.photoImageView ip_addTopBorderWithWidth:0.5 color:[UIColor lightGrayColor]];
    [self.photoImageView ip_addBottomBorderWithWidth:0.5 color:[UIColor lightGrayColor]];
    self.progressView.borderWidth = 0;
}

- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsZero;
}

#pragma mark - UITableViewCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.photoImageView.image = nil;
    self.photoImageView.alpha = 0;
}

#pragma mark - Properties

- (void)setMediaItem:(InstagramMediaItem *)mediaItem {
    _mediaItem = mediaItem;
    [self updateUIWithItem:mediaItem];
}

#pragma mark - Private

- (void)updateUIWithItem:(InstagramMediaItem *)mediaItem {
    self.authorLabel.text = mediaItem.author.username;
    self.creationDateLabel.text = [self.dateFormatter stringFromDate:mediaItem.creationDate];
    self.commentsLabel.attributedText = [[self class] attributedStringFromComments:mediaItem.comments];
    
    id<ImageDownloadModel> downloadModel = [[JSObjection defaultInjector] getObject:@protocol(ImageDownloadModel)];
    
    ImageDownloadProgressTicket *ticket = [downloadModel ticketForUrl:mediaItem.imageUrlString];
    if (!ticket) {
        ticket = [downloadModel downloadImageForUrl:mediaItem.imageUrlString];
    }
    if (self.imageTicket) {
        [self.imageTicket removeObserver:self forKeyPath:@"progress"];
        self.imageTicket = nil;
    }

    if (ticket.image) {
        self.photoImageView.image = ticket.image;
        self.photoImageView.alpha = 1;
        [self.progressView setProgress:0 animated:NO];
    } else {
        self.imageTicket = ticket;
        [self.progressView setProgress:self.imageTicket.progress animated:YES];
        [self.imageTicket addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    }
    [self updateProgressLabel];
}

- (void)updateProgressLabel {
    if (self.imageTicket.image || !self.imageTicket) {
        self.progressLabel.text = @"";
        return;
    }
    
    self.progressLabel.text = [NSString stringWithFormat:@"%@%%", @((int)(self.imageTicket.progress * 100))];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self.progressView setProgress:self.imageTicket.progress animated:YES];
    self.progressView.progress = self.imageTicket.progress;
    if (self.imageTicket.image) {
        [self.progressView setProgress:0 animated:NO];
        self.photoImageView.image = self.imageTicket.image;
        [UIView animateWithDuration:0.3 animations:^{
            self.photoImageView.alpha = 1;
        }];
        [self.imageTicket removeObserver:self forKeyPath:@"progress"];
        self.imageTicket = nil;
    }
    [self updateProgressLabel];
}

@end
