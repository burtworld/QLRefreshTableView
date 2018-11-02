//
//  QLRefreshTableView.h
//  QLRefreshTableView
//
//  Created by paramita on 2018/10/16.
//  Copyright © 2018 paramita. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QLRefreshTableViewType) {
    QLRefreshTableViewTypeNone = 0,     /// 不刷新
    QLRefreshTableViewTypeTop,          /// 下拉
    QLRefreshTableViewTypeBottom,       /// 上划
    QLRefreshTableViewTypeAll           /// 均使用
};

@interface QLPageModel : NSObject

/// 识别串
@property (nonatomic,copy) NSString *identify;
/// 当前页码
@property (nonatomic,assign) NSInteger page;
/// 总数
@property (nonatomic,assign) NSInteger allCount;
///
@property (nonatomic,assign) NSInteger pageSize;
@end


@class QLRefreshTableView;
@protocol QLRefreshTableViewDelegate <NSObject>

/**
 刷新代理，代理只需要做取数据的事即可

 @param tableView tableView
 @param pager 页码模型
 @param completeBlock 完成事件 recordCount 为当次取得的记录数
 */
- (void)tableView:(QLRefreshTableView *)tableView refreshWithPageModel:(QLPageModel *)pager complete:(void(^)(NSInteger recordCount))completeBlock;
@end

/**
 依赖库：
 
 1.MJRefresh
 
 2.DZNEmptyDataSet
 
 3.RealReachability
 */
@interface QLRefreshTableView : UITableView

@property (nonatomic,assign) QLRefreshTableViewType refreshType;

/// 是否正在加载中
@property (nonatomic,assign) BOOL isLoading;
@property (nonatomic,weak) id<QLRefreshTableViewDelegate>refreshDelegate;

/**
是否需要显示无数据的界面 默认为YES，如果显示的话，可以自定义title image等

@also see `emptySetTitle`
 
@also see `emptySetImage`
 
@also see `emptySetDescription`
 */
@property (nonatomic,assign) BOOL needShowEmptySet;

/// 无数据时的标题
@property (nonatomic,copy) NSAttributedString *emptySetTitle;

/// 无数据时的描述
@property (nonatomic,copy) NSAttributedString *emptySetDescription;

/// 无数据时的图片
@property (nonatomic,strong) UIImage *emptySetImage;

/// 正在加载时的图片
@property (nonatomic,strong) UIImage *loadingImage;

/// 进入刷新
- (void)beginRefreshWithBlock:(nullable void(^)(void))block;
@end

NS_ASSUME_NONNULL_END
