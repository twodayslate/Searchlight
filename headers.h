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
@end

@interface SBSearchHeader
-(UITextField *)searchField;
@end

@interface SBSearchTableViewCell : UITableViewCell
-(void)setTitle:(id)arg1;
-(void)setFirstInSection:(BOOL)arg1 ;
-(void)setIsLastInSection:(BOOL)arg1 ;
-(void)setTitleImage:(id)arg1 animated:(BOOL)arg2 ;
-(void)setHasImage:(BOOL)arg1 ;
@end

@interface SpringBoard
-(BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2 ;
@end

@interface SBSearchTableHeaderView : UIView 
-(void)setTitle:(id)arg1 ;
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
-(id)identifiers;
-(void)remove:(id)arg1;
@end