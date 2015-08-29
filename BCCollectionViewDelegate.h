//  Created by Pieter Omvlee on 25/11/2010.
//  Copyright 2010 Bohemian Coding. All rights reserved.

#import <Cocoa/Cocoa.h>

@class BCCollectionView, BCCollectionViewGroup;

enum {
  BCCollectionViewScrollDirectionUp   = 0,
  BCCollectionViewScrollDirectionDown = 1
};

@protocol BCCollectionViewDelegate <NSObject>
@required
//CollectionView assumes all cells aer the same size and will resize its subviews to this size.
- (NSSize)cellSizeForCollectionView:(BCCollectionView *)collectionView;

//Return an empty ViewController, this might not be visible to the user immediately
- (NSViewController *)reusableViewControllerForCollectionView:(BCCollectionView *)collectionView;

//The CollectionView is about to display the ViewController. Use this method to populate the ViewController with data
- (void)collectionView:(BCCollectionView *)collectionView willShowViewController:(NSViewController *)viewController forItem:(id)anItem atIndex:(NSUInteger)anIndex;

@optional
//the viewController has been removed from view and storen for reuse. You can uload any resources here
- (void)collectionView:(BCCollectionView *)collectionView viewControllerBecameInvisible:(NSViewController *)viewController;

- (void)collectionView:(BCCollectionView *)collectionView updateViewControllerAsSelected:(NSViewController *)viewController forItem:(id)item;
- (void)collectionView:(BCCollectionView *)collectionView updateViewControllerAsDeselected:(NSViewController *)viewController forItem:(id)item;

//managing selections. dont update the viewController do relfect select status. use the methods above instead
- (BOOL)collectionView:(BCCollectionView *)collectionView shouldSelectItem:(id)anItem withViewController:(NSViewController *)viewController;
- (void)collectionView:(BCCollectionView *)collectionView didSelectItem:(id)anItem withViewController:(NSViewController *)viewController;
- (void)collectionView:(BCCollectionView *)collectionView didDeselectItem:(id)anItem withViewController:(NSViewController *)viewController;
- (void)collectionViewSelectionDidChange:(BCCollectionView *)collectionView;

- (void)collectionView:(BCCollectionView *)collectionView didClickItem:(id)anItem withViewController:(NSViewController *)viewController;

- (void)collectionViewDidScroll:(BCCollectionView *)collectionView inDirection:(NSUInteger)scrollDirection;
- (void)collectionView:(BCCollectionView *)collectionView didDoubleClickViewControllerAtIndex:(NSViewController *)viewController;
- (void)collectionView:(BCCollectionView *)collectionView didReceivePressureEvent:(NSEvent*)pressureEvent withViewController:(NSViewController *)viewController;
- (NSSize)insetMarginForSelectingItemsInCollectionView:(BCCollectionView *)collectionView;

//defaults to YES
- (BOOL)collectionViewShouldDrawSelections:(BCCollectionView *)collectionView;
- (BOOL)collectionViewShouldDrawHover:(BCCollectionView *)collectionView;
- (BOOL)collectionViewShouldDrawSelectionRect:(BCCollectionView *)collectionView;

//working with groups
- (NSUInteger)groupHeaderHeightForCollectionView:(BCCollectionView *)collectionView;
- (NSViewController *)collectionView:(BCCollectionView *)collectionView headerForGroup:(BCCollectionViewGroup *)group;
- (NSInteger)topOffsetForItemsInCollectionView:(BCCollectionView *)collectionView;

//managing Drag & Drop (in order of occurence)
- (BOOL)collectionView:(BCCollectionView *)collectionView canDragItemsAtIndexes:(NSIndexSet *)indexSet;
- (void)collectionView:(BCCollectionView *)collectionView writeItemsAtIndexes:(NSIndexSet *)indexSet toPasteboard:(NSPasteboard *)pboard;
- (NSImage*)collectionView:(BCCollectionView *)collectionView dragImageForItemsAtIndexes:(NSIndexSet*)indexSet;
- (BOOL)collectionView:(BCCollectionView *)collectionView validateDrop:(id <NSDraggingInfo>)draggingInfo onItemAtIndex:(NSInteger)index;
- (void)collectionView:(BCCollectionView *)collectionView dragEnteredViewController:(NSViewController *)viewController;
- (void)collectionView:(BCCollectionView *)collectionView dragExitedViewController:(NSViewController *)viewController;
- (BOOL)collectionView:(BCCollectionView *)collectionView
  performDragOperation:(id <NSDraggingInfo>)draggingInfo
      onViewController:(NSViewController *)viewController
               forItem:(id)item;
- (NSDragOperation)collectionView:(BCCollectionView *)collectionView draggingEntered:(id <NSDraggingInfo>)draggingInfo;
- (void)collectionView:(BCCollectionView *)collectionView draggingEnded:(id <NSDraggingInfo>)draggingInfo;
- (void)collectionView:(BCCollectionView *)collectionView draggingExited:(id <NSDraggingInfo>)draggingInfo;
- (NSData*)collectionView:(BCCollectionView *)collectionView dragDataForItemsAtIndexes:(NSIndexSet*)indexes;
- (NSArray*)collectionView:(BCCollectionView *)collectionView filenamesForItemsAtIndexes:(NSIndexSet*)indexes;
- (BOOL)collectionView:(BCCollectionView *)collectionView dragFilePromisesWithDataType:(NSString**)dataType;

//key events
- (void)collectionView:(BCCollectionView *)collectionView deleteItemsAtIndexes:(NSIndexSet *)indexSet;
- (BOOL)collectionView:(BCCollectionView *)collectionView nameOfItem:(id)anItem startsWith:(NSString *)startingString;

//magnifiy events. This method is required BCCollectionView+Zoom is included
- (NSRange)validScalingRangeForCollectionView:(BCCollectionView *)collectionView;
- (float)magnificationVelocityForCollectionView:(BCCollectionView *)collectionView; // determines how fast the view should zoom while using the pinch gesture. Can vary depending on how large your validScalingRange is. In my app I have a range of 0..100 and use a magnificationVelocity of (scalingRange.length - scalingRange.location)/2

- (void)collectionViewDidZoom:(BCCollectionView *)collectionView;

//contextual menu
- (NSMenu *)collectionView:(BCCollectionView *)collectionView menuForItemsAtIndexes:(NSIndexSet *)indexSet;

- (void)collectionViewLostFirstResponder:(BCCollectionView *)collectionView;
- (void)collectionViewBecameFirstResponder:(BCCollectionView *)collectionView;

@end
