//
//  QLRefreshTableView.m
//  QLRefreshTableView
//
//  Created by paramita on 2018/10/16.
//  Copyright © 2018 paramita. All rights reserved.
//

#import "QLRefreshTableView.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <MJRefresh/MJRefresh.h>
#import <RealReachability/RealReachability.h>


@implementation QLPageModel

@end

@interface QLRefreshTableView()<DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property (nonatomic,assign) ReachabilityStatus reachabilityStatus;
@property (nonatomic,strong) QLPageModel *pageModel;
@end

@implementation QLRefreshTableView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initializer];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializer];
    }
    return self;
}

- (void)initializer {
    self.needShowEmptySet = YES;
    __weak typeof(self)weakself = self;
    /// 开启网络状态监听
    [GLobalRealReachability reachabilityWithBlock:^(ReachabilityStatus status) {
        weakself.reachabilityStatus = status;
    }];
    
}

#pragma mark - getter and setter
- (void)setNeedShowEmptySet:(BOOL)needShowEmptySet {
    _needShowEmptySet = needShowEmptySet;
    if (needShowEmptySet) {
        [self addEmptyDataSet];
    }else{
        [self removeEmptyDataSet];
    }
}

- (void)setRefreshType:(QLRefreshTableViewType)refreshType {
    _refreshType = refreshType;
    if (refreshType == QLRefreshTableViewTypeAll) {
        [self addPullToRefresh];
        [self addPushToRefresh];
    }else if (refreshType == QLRefreshTableViewTypeTop) {
        [self addPullToRefresh];
        self.mj_footer = nil;
    }else if (refreshType == QLRefreshTableViewTypeBottom) {
        [self addPushToRefresh];
        self.mj_header = nil;
    }else if (refreshType == QLRefreshTableViewTypeNone) {
        self.mj_header = nil;
        self.mj_footer = nil;
    }
}

- (QLPageModel *)pageModel {
    if (!_pageModel) {
        _pageModel = [QLPageModel new];
        _pageModel.pageSize = 10;
        _pageModel.page = 1;
    }
    return _pageModel;
}

#pragma mark - Actions
- (void)addEmptyDataSet {
    self.emptyDataSetSource = self;
    self.emptyDataSetDelegate = self;
}

- (void)removeEmptyDataSet {
    self.emptyDataSetSource = nil;
    self.emptyDataSetDelegate = nil;
}

- (void)addPullToRefresh {
    __weak __typeof(self) weakSelf = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader new];
    header.lastUpdatedTimeLabel.hidden = true;
    [header setBeginRefreshingCompletionBlock:^{

        weakSelf.pageModel.page = 1;
        weakSelf.pageModel.allCount = 0;
        [weakSelf beginRefreshWithBlock:NULL];
    }];

    self.mj_header = header;
}

- (void)addPushToRefresh {
    __weak __typeof(self) weakSelf = self;
    
    MJRefreshAutoNormalFooter *footer  = [MJRefreshAutoNormalFooter new];
    footer.refreshingTitleHidden = true;
    [footer setTitle:@"没有数据了" forState:MJRefreshStateNoMoreData];
    [footer setBeginRefreshingCompletionBlock:^{
        weakSelf.pageModel.page++;
        [weakSelf beginRefreshWithBlock:NULL];
    }];
    self.mj_footer = footer;
}

- (void)beginRefreshWithBlock:(nullable void(^)(void))block {

    if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(tableView:refreshWithPageModel:complete:)]) {
        __weak typeof(self)weakself = self;
        self.isLoading = YES;
        [self.refreshDelegate tableView:self refreshWithPageModel:self.pageModel complete:^(NSInteger recordCount) {
            if (block) {
                block();
            }
            weakself.isLoading = NO;
            if (weakself.pageModel.page == 1) {
                weakself.pageModel.allCount = recordCount;
            }else{
                weakself.pageModel.allCount += recordCount;
            }
            if (recordCount < weakself.pageModel.pageSize) {
                [weakself.mj_footer endRefreshingWithNoMoreData];
            }else{
                [weakself.mj_footer endRefreshing];
            }
            [weakself.mj_header endRefreshing];
        }];
    }
}

- (NSAttributedString *)attributeStringWithFont:(UIFont *)font textColor:(UIColor *)color text:(NSString *)text {
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (color) [attributes setObject:color forKey:NSForegroundColorAttributeName];
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}


#pragma mark - DZNEmptyDataSetSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    if (self.reachabilityStatus > 0) {
        if (!self.emptySetTitle) {
            return [self attributeStringWithFont:[UIFont boldSystemFontOfSize:18.0]
                                       textColor:[UIColor lightTextColor]
                                            text:@"没有获取到数据"];
        }
        return self.emptySetTitle;
    }else{
        return [self attributeStringWithFont:[UIFont boldSystemFontOfSize:18.0]
                                   textColor:[UIColor lightTextColor]
                                        text:@"网络断开了"];
    }
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    if (!self.emptySetDescription) {
        return [self attributeStringWithFont:[UIFont boldSystemFontOfSize:18.0]
                                   textColor:[UIColor lightTextColor]
                                        text:@"点击即可重新加载"];
    }
    return self.emptySetDescription;
}

/// 返回单张图片
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    
    if (self.isLoading) {
        
        return self.loadingImage ? self.loadingImage : [UIImage imageNamed:@"loading_imgBlue_78x78" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    }else{
        if (self.reachabilityStatus > 0) {
            return self.emptySetImage ? self.emptySetImage : [UIImage imageNamed:@"placeholder_appstore" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        }else{
            return self.emptySetImage ? self.emptySetImage : [UIImage imageNamed:@"placeholder_remote" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        }
    }
}
#pragma mark - DZNEmptyDataSetDelegate
- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    if (!self.isLoading && self.reachabilityStatus > 0) {
        /// 开始刷新
        [self beginRefreshWithBlock:NULL];
    }
}

@end
