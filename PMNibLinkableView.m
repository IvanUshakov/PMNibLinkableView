//
//  PMNibLinkableView.m
//  MyDreams
//
//  Created by Anatoliy Peshkov on 21/06/2016.
//  Copyright © 2016 Perpetuum Mobile lab. All rights reserved.
//

#import "PMNibLinkableView.h"
#import <objc/runtime.h>

@interface PMNibLinkableView ()
@property (nonatomic, strong) NSMutableArray *awakedClasses;
@property (nonatomic, strong) UIView *originalView;
@end

@implementation PMNibLinkableView

static int kPMNibLinkableViewTag = 999;

+ (void)initialize
{
    [super initialize];
    [self swizzleAwakeFromNib];
}

+ (void)swizzleAwakeFromNib
{
    Class class = [self class];
    SEL originalSelector = @selector(awakeFromNib);
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    void (*originalImp)(id, SEL) = (void (*)(id, SEL))method_getImplementation(originalMethod);

    IMP blockImpl = imp_implementationWithBlock(^(PMNibLinkableView *self) {

        if (self.originalView != nil) {
            [self copyViewProperties];
        }

        if (!self.awakedClasses) {
            self.awakedClasses = [NSMutableArray array];
        }

        NSString *className = NSStringFromClass(class);
        if (![self.awakedClasses containsObject:className]) {
            [self.awakedClasses addObject:className];
            originalImp(self, @selector(awakeFromNib));
        }
    });

    BOOL didAddMethod = class_addMethod(class, originalSelector, blockImpl, method_getTypeEncoding(originalMethod));

    if (!didAddMethod) {
        method_setImplementation(originalMethod, blockImpl);
    }
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder
{
    if (self.subviews.count != 0 && self.tag != kPMNibLinkableViewTag) {
        return [super awakeAfterUsingCoder:aDecoder];
    }

    NSString *xibFileName = [NSStringFromClass([self class]) componentsSeparatedByString:@"."].lastObject;
    PMNibLinkableView *loadedView = [[[NSBundle mainBundle] loadNibNamed:xibFileName owner:nil options:nil] firstObject];
    loadedView.originalView = self;

    return loadedView;
}

// MARK: - Private

- (void)copyViewProperties
{
    self.frame = self.originalView.frame;
    self.alpha = self.originalView.alpha;
    self.autoresizingMask = self.originalView.autoresizingMask;
    self.translatesAutoresizingMaskIntoConstraints = self.originalView.translatesAutoresizingMaskIntoConstraints;

    [self copySubview];
    [self copyConstrains];

    self.originalView = nil;
}

- (void)copySubview
{
    for (UIView *view in self.originalView.subviews) {
        [self addSubview:view];
    }
}

- (void)copyConstrains
{
    for (NSLayoutConstraint *constraint in self.originalView.constraints) {
        id firstItem = (constraint.firstItem == self.originalView)? self : constraint.firstItem;
        id secondItem = (constraint.secondItem == self.originalView)? self : constraint.secondItem;

        if (firstItem) {
            NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:firstItem
                                                                             attribute:constraint.firstAttribute
                                                                             relatedBy:constraint.relation
                                                                                toItem:secondItem
                                                                             attribute:constraint.secondAttribute
                                                                            multiplier:constraint.multiplier
                                                                              constant:constraint.constant];
            newConstraint.priority = constraint.priority;
            newConstraint.identifier = constraint.identifier;
            [self addConstraint:newConstraint];
        }
    }
}

@end
