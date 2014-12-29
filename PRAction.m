#import "PRAction.h"
#import "PRCore.h"
#import "PRDb.h"
#import "PRPlaylists.h"
#import "PRNowPlayingController.h"
#import "PRNowPlayingViewController_Private.h"
#import "PRMainWindowController.h"
#import "PRLibraryViewController.h"
#import "PRBrowserViewController.h"
#import "PRPlaylistsViewController.h"


@implementation PRAction {
    __weak PRCore *_core;
}

@synthesize core = _core;

@end

@implementation PRClearNowPlayingAction

- (void)main {
    PRCore *core = [self core];
    dispatch_sync(dispatch_get_main_queue(), ^{
        int count = [[[core db] playlists] countForList:[[core now] currentList]];
        if (count == 1 || [[core now] currentIndex] == 0) {
            // if nothing playing or count == 1, clear playlist
            [[core now] stop];
            [[[core db] playlists] clearList:[[core now] currentList]];
        } else {
            // otherwise delete all previous songs
            [[[core db] playlists] clearList:[[core now] currentList] exceptIndex:[[core now] currentIndex]];
        }
        [[NSNotificationCenter defaultCenter] postListItemsDidChange:[[core now] currentList]];
    });
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[[core win] nowPlayingViewController] collapseAll];
    });
}

@end

@implementation PRAddNowPlayingAction {
    NSArray *_items;
    NSInteger _index;
}

@synthesize items = _items;
@synthesize index = _index;

- (void)main {
    // // Adding
    // NSMutableArray *beforeArray = [NSMutableArray array];
    // NSMutableArray *afterArray = [NSMutableArray array];
    // int albumCount = [self outlineView:nowPlayingTableView numberOfChildrenOfItem:nil];
    // for (int i = 0; i < albumCount; i++) {
    //     NSArray *item = [self itemForItem:@[@(i)]];
    //     NSRange range = [self dbRangeForParentItem:item];
    //     if (range.location == _index) {
    //         break;
    //     }
    //     [beforeArray addObject:@([nowPlayingTableView isItemExpanded:item])];
    //     if (NSLocationInRange(_index, range)) {
    //         break;
    //     }
    // }
    // if (_index <= [self _indexCount]) {
    //     for (int i = albumCount - 1; i >= 0 ; i--) {
    //         NSArray *item = [self itemForItem:@[@(i)]];
    //         [afterArray addObject:@([nowPlayingTableView isItemExpanded:item])];
    //         NSRange range = [self dbRangeForParentItem:item];
    //         if (NSLocationInRange(_index, range)) {
    //             break;
    //         }
    //     }
    // }
    
    // // Checks if adding single album
    // BOOL singleAlbum = YES;
    // if ([_items count] > 1) {
    //     NSString *artist = [[_db library] artistValueForItem:[_items objectAtIndex:0]];
    //     NSString *album = [[_db library] valueForItem:[_items objectAtIndex:0] attr:PRItemAttrAlbum];
    //     for (NSNumber *i in _items) {
    //         NSString *nextArtist = [[_db library] artistValueForItem:i];
    //         NSString *nextAlbum = [[_db library] valueForItem:i attr:PRItemAttrAlbum];
    //         if (![artist isEqualToString:nextArtist] || ![album isEqualToString:nextAlbum]) {
    //             singleAlbum = NO;
    //         }
    //     }
    // }
    
    // [[_db playlists] addItems:_items atIndex:_index toList:[now currentList]];
    // [[NSNotificationCenter defaultCenter] postListItemsDidChange:[now currentList]];
    // [nowPlayingTableView selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
    // [nowPlayingTableView collapseItem:nil];
    
    // albumCount = [self outlineView:nowPlayingTableView numberOfChildrenOfItem:nil];
    // for (int i = 0; i < [beforeArray count]; i++) {
    //     id item = [self itemForItem:@[[NSNumber numberWithInt:i]]];
    //     if ([[beforeArray objectAtIndex:i] boolValue]) {
    //         [nowPlayingTableView expandItem:item];
    //     } else {
    //         [nowPlayingTableView collapseItem:item];
    //     }
    // }
    // for (int i = 0; i < [afterArray count]; i++) {
    //     id item = [self itemForItem:@[[NSNumber numberWithInt:albumCount - i - 1]]];
    //     if ([[afterArray objectAtIndex:i] boolValue]) {
    //         [nowPlayingTableView expandItem:item];
    //     } else {
    //         [nowPlayingTableView collapseItem:item];
    //     }
    // }
    
    // if (singleAlbum) {
    //     id item = [self itemForItem:@[@([beforeArray count])]];
    //     [nowPlayingTableView expandItem:item];
    // }
}

@end


@implementation PRBlockAction

+ (instancetype)blockActionWithBlock:(void (^)(PRCore *))block {
    PRBlockAction *action = [[[self class] alloc] init];
    [action setBlock:block];
    return action;
}

- (void)main {
    dispatch_sync(dispatch_get_main_queue(), ^{
        _block([self core]);
    });
}
@end


@implementation PRPlayNextAction

- (void)main {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[[self core] now] playNext];
    });
}

@end


@implementation PRPlayPreviousAction

- (void)main {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[[self core] now] playPrevious];
    });
}

@end


@implementation PRStopAction

- (void)main {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[[self core] now] stop];
    });
}

@end


@implementation PRPlayItemAtIndexAction {
    NSInteger _index;
}

@synthesize index = _index;

- (void)main {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[[self core] now] playItemAtIndex:_index];
    });
}

@end

@implementation PRHighlightItemsAction {
    NSArray *_items;
}

@synthesize items = _items;

- (void)main {
    PRMainWindowController *win = [[self core] win];
    PRPlaylists *playlists = [[[self core] db] playlists];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [win setCurrentMode:PRLibraryMode];
        [[win libraryViewController] setCurrentList:[playlists libraryList]];
        [[[win libraryViewController] currentViewController] highlightItem:[_items firstObject]];
    });
}

@end

@implementation PRDuplicatePlaylistAction {
    PRList *_list;
}

@synthesize list = _list;

- (void)main {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[[[self core] win] playlistsViewController] duplicatePlaylist:[_list integerValue]];
    });
}

@end

@implementation PRPlayItemsAction

- (void)main {
    dispatch_sync(dispatch_get_main_queue(), ^{
        PRNowPlayingController *now = [[self core] now];
        PRPlaylists *playlists = [[[self core] db] playlists];
        [now stop];
        [playlists clearList:[now currentList]];
        for (PRItem *i in [self items]) {
            [playlists zAppendItem:i toList:[now currentList]];
        }
        [[NSNotificationCenter defaultCenter] postListItemsDidChange:[now currentList]];
        [now playItemAtIndex:[self index]+1];
    });
}

@end

@implementation PRAddItemsToListAction

- (void)main {
    dispatch_sync(dispatch_get_main_queue(), ^{
        PRNowPlayingController *now = [[self core] now];
        PRList *list = [self list] ?: [now currentList];
        PRPlaylists *playlists = [[[self core] db] playlists];
        for (PRItem *i in [self items]) {
            [playlists zAppendItem:i toList:list];
        }
        [[NSNotificationCenter defaultCenter] postListItemsDidChange:list];
    });
}

@end

@implementation PRSetListDescriptionAction

- (void)main {
    dispatch_sync(dispatch_get_main_queue(), ^{
        PRPlaylists *playlists = [[[self core] db] playlists]; 
        [playlists zSetListDescription:[self listDescription] forList:[self list]];
        
        PRListChange *listChange = [[PRListChange alloc] init];
        [listChange setList:[self list]];
        PRChangeSet *changeSet = [[PRChangeSet alloc] init];
        [changeSet setChanges:@[listChange]];
        [[NSNotificationCenter defaultCenter] postBackendChanged:changeSet];
    });
}

@end

@implementation PRRevealAction

- (void)main {
}

@end

@implementation PRDeleteItemsAction

- (void)main {
    // if ([indexes count] == 0) {
    //     return;
    // }
    // if (![_currentList isEqual:[[_db playlists] libraryList]]) {
    //     NSMutableIndexSet *indexesToDelete = [NSMutableIndexSet indexSet];
    //     NSTableColumn *tableColumn = [_tableView tableColumnWithIdentifier:PRListSortIndex];
    //     [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    //         [indexesToDelete addIndex:[[self tableView:_tableView objectValueForTableColumn:tableColumn row:idx] intValue]];
    //     }];
    //     [[_db playlists] removeItemsAtIndexes:indexesToDelete fromList:_currentList];
        
    //     [[NSNotificationCenter defaultCenter] postListItemsDidChange:_currentList];
    //     [_tableView selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
    // } else {
    //     NSString *message = @"Do you want to remove the selected song from your library?";
    //     if ([indexes count] != 1) {
    //         message = [NSString stringWithFormat:@"Do you want to remove the %lu selected songs from your library?", (unsigned long)[indexes count]];
    //     }
    //     NSAlert *alert = [[NSAlert alloc] init];
    //     [alert addButtonWithTitle:@"Remove"];
    //     [alert addButtonWithTitle:@"Cancel"];
    //     [alert setMessageText:message];
    //     [alert setInformativeText:@"These files will not be deleted from your computer"];
    //     [alert setAlertStyle:NSWarningAlertStyle];
    //     [alert beginSheetModalForWindow:[[self view] window] 
    //                       modalDelegate:self 
    //                      didEndSelector:@selector(deleteAlertDidEnd:returnCode:contextInfo:)
    //                         contextInfo:(__bridge_retained void *)indexes];
    // }
    
    // NSIndexSet *indexes = (__bridge_transfer NSIndexSet *)contextInfo;
    // if (returnCode != NSAlertFirstButtonReturn) {
    //     return;
    // }
    // NSMutableArray *items = [NSMutableArray array];
    // [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    //     [items addObject:[[_db libraryViewSource] itemForRow:[self dbRowForTableRow:idx]]];
    // }];
    // if ([items containsObject:[_now currentItem]]) {
    //     [_now stop];
    // }
    // [[_db library] removeItems:items];
    // [[NSNotificationCenter defaultCenter] postLibraryChanged];
    // [[NSNotificationCenter defaultCenter] postListItemsDidChange:[_now currentList]];
    // [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];    
}

@end
