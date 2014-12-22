
@interface ALApplicationList 
@property (nonatomic, readonly) NSDictionary *applications;
-(id)sharedApplicationList;
- (id)valueForKey:(NSString *)keyPath forDisplayIdentifier:(NSString *)displayIdentifier;
-(NSInteger)applicationCount;
- (UIImage *)iconOfSize:(int)iconSize forDisplayIdentifier:(NSString *)displayIdentifier;
@end

@interface SBSearchViewController : UITableViewController <UITableViewDataSource> {
}
-(BOOL)shouldDisplayListLauncher;
-(void)dismiss;
-(void)_fadeForLaunchWithDuration:(double)arg1 completion:(/*^block*/ id)arg2 ;
-(int)numberOfSectionsInTableView:(id)arg1;
-(void)_updateTableContents;
+(id)sharedInstance;
-(id)sectionIndexTitlesForTableView:(id)arg1;
-(int)tableView:(id)arg1 sectionForSectionIndexTitle:(id)arg2 atIndex:(int)arg3;
-(id)applicationList;
-(id)sortedDisplayIdentifiers;
-(void)_setShowingKeyboard:(BOOL)arg1 ;
-(void)searchGesture:(id)arg1 completedShowing:(BOOL)arg2 ;
-(float)tableView:(id)arg1 heightForRowAtIndexPath:(id)arg2;
-(BOOL)_hasNoQuery;
-(void)_lockScreenUIWillLock:(id)arg1 ;
@end

@interface UITableView (addons)
- (void)_setHeight:(float)arg1 forRowAtIndexPath:(id)arg2;
-(id)_tableHeaderBackgroundView;
@end

@interface SBSearchHeader
-(UITextField *)searchField;
@end

@interface UITableViewCell (extras)
- (void)_setBackgroundInset:(UIEdgeInsets)arg1;
- (void)setSeparatorInset:(UIEdgeInsets)arg1;

@end

@interface SBSearchTableViewCell : UITableViewCell {
	float _leftSeparatorMargin;
}
+(void)initialize;
-(void)setTitle:(id)arg1;
-(void)setFirstInSection:(BOOL)arg1 ;
-(void)setIsLastInSection:(BOOL)arg1 ;
-(void)setTitleImage:(id)arg1 animated:(BOOL)arg2 ;
-(void)setHasImage:(BOOL)arg1 ;
@property (assign) float leftSeparatorMargin; 
@property (nonatomic,readonly) UIView * background;  
-(void)setLeftSeparatorMargin:(float)arg1 ;
-(void)updateConstraints;
-(void)clipToTopHeaderWithHeight:(float)arg1 inTableView:(id)arg2 ;
-(UIView *)clippingContainer;
@end

@interface SBSearchStandardCell : SBSearchTableViewCell
@property (nonatomic,readonly) UILabel* titleLabel; 
-(float)leftTextMargin;
-(void)updateLabel:(id)arg1 withValue:(id)arg2 ;
-(void)updateFonts;
-(id)leftTextView;
-(UIView *)leftView;
@end

@interface SpringBoard
-(BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2 ;
@end

@interface SBSearchTableHeaderView : UIView 
-(void)setTitle:(id)arg1;
-(id)initWithReuseIdentifier:(id)arg1 ;
-(id)separatorView;
-(id)recursiveDescription;
@end

@interface SBIcon
-(void)launchFromLocation:(int)arg1;
@end

@interface SBIconModel
-(id)expectedIconForDisplayIdentifier:(id)arg1 ;
@end

@interface SBIconController
-(id)sharedInstance;
-(SBIconModel *)model;
@end

@interface SBAppSwitcherModel : NSObject {
	NSMutableArray* _recentDisplayIdentifiers;
}
+(id) sharedInstance;
-(id)_recentFromPrefs;
-(void)_saveRecents;
-(void)appsRemoved:(id)arg1 added:(id)arg2;
-(id)snapshot;
-(id)snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary;
-(void)remove:(id)arg1;
@end

@interface SBSearchImageCell : SBSearchStandardCell  {
	UIImageView* _titleImageView;
}
@property (nonatomic,readonly) UILabel* titleLabel; 
@property (nonatomic,readonly) UIImageView* titleImageView;
+(id)placeHolderImageForDomain:(unsigned)arg1 result:(id)arg2 size:(CGSize)arg3 ;
-(void)updateWithSection:(id)arg1 result:(id)arg2 traitCollection:(id)arg3 ;
-(void)setTitleTextAttributes:(id)arg1 ;
- (id)leftTextView;
- (id)leftView;
- (id)variableConstraints;
- (id)constantConstraints;
-(id)recursiveDescription;
@end

@interface UIFont (extras)
+ (UIFont *)fontWithName:(NSString *)fontName size:(CGFloat)fontSize;
@end

@interface SPSearchResult
-(id)initWithData:(id)arg1 ;
-(void)setTitle:(id)arg1 ;
-(void)setUrl:(id)arg1 ;
@end

@interface SBSearchModel
@end

@interface SBSearchTableView : UITableView
@end