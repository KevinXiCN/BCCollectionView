//  Created by Pieter Omvlee on 13/12/2010.
//  Copyright 2010 Bohemian Coding. All rights reserved.

#import "BCCollectionView+Dragging.h"
#import "BCCollectionViewLayoutManager.h"

@interface BCCollectionView ()
{
	BOOL firstDrag;
}

@end

@implementation BCCollectionView (BCCollectionView_Dragging)

- (NSImage*) imageForCurrentSelectionWithItemRect:(NSRect*)itemRect {
    
    // we see if we can get a dragged image from our delegate
    NSIndexSet *indexes = nil;
    if ([self selectionIndexes])
        indexes = [self selectionIndexes];
    else {
        NSUInteger index = [layoutManager indexOfItemAtPoint:mouseDownLocation];
        indexes = [NSIndexSet indexSetWithIndex:index];
    }
    NSImage *dragImage;
    if ([delegate respondsToSelector:@selector(collectionView:dragImageForItemsAtIndexes:)]) {
        dragImage = [delegate collectionView:self dragImageForItemsAtIndexes:indexes];
        NSUInteger index = [layoutManager indexOfItemAtPoint:mouseDownLocation];
        *itemRect     = [layoutManager rectOfItemAtIndex:index];
    } else {
        NSInteger index = [indexes firstIndex];
        [self selectItemAtIndex:index];
        
        *itemRect     = [layoutManager rectOfItemAtIndex:index];
        NSView *currentView = [[self viewControllerForItemAtIndex:index] view];
        NSData *imageData   = [currentView dataWithPDFInsideRect:NSMakeRect(0,0,NSWidth(*itemRect),NSHeight(*itemRect))];
        NSImage *pdfImage   = [[NSImage alloc] initWithData:imageData];
        NSImage *dragImage  = [[NSImage alloc] initWithSize:[pdfImage size]];
        
        if ([dragImage size].width > 0 && [dragImage size].height > 0) {
            [dragImage lockFocus];
            [pdfImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.5];
            [dragImage unlockFocus];
        }
    }
    
    return dragImage;
}

- (void)initiateDraggingSessionWithEvent:(NSEvent *)anEvent
{
    // we see if we should drag file promises. 10.6 style.
    if ([delegate respondsToSelector:@selector(collectionView:dragFilePromisesWithDataType:)]) {
        NSString *datatype = nil;
        if ([delegate collectionView:self dragFilePromisesWithDataType:&datatype]) {
            [self dragPromisedFilesOfTypes:[NSArray arrayWithObject:datatype]
                                  fromRect:[self frame]
                                    source:self
                                 slideBack:YES
                                     event:anEvent];
            return;
        }
    }
    
    // otherwise we begin a normal drag image
    NSRect itemRect;
    NSImage *dragImage = [self imageForCurrentSelectionWithItemRect:&itemRect];
    NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    
    [self delegateWriteIndexes:selectionIndexes toPasteboard:pasteboard];
    [super dragImage:dragImage
                  at:NSMakePoint(NSMinX(itemRect), NSMaxY(itemRect))
              offset:NSMakeSize(0, 0)
               event:anEvent
          pasteboard:pasteboard
              source:self
           slideBack:YES];
}


- (void)dragImage:(NSImage *)anImage at:(NSPoint)viewLocation offset:(NSSize)initialOffset
            event:(NSEvent *)theEvent pasteboard:(NSPasteboard *)pboard source:(id)sourceObj slideBack:(BOOL)slideFlag {
    
    NSData *dragData = nil;
    if ([self.delegate respondsToSelector:@selector(collectionView:dragDataForItemsAtIndexes:)] ) {
        dragData = [self.delegate collectionView:self dragDataForItemsAtIndexes:[self selectionIndexes]];
    }

    // WHY?? Unknown definition `ALBUMIMAGEDATATYPE`.
    //[pboard addTypes:[NSArray arrayWithObjects:ALBUMIMAGEDATATYPE, NSFilesPromisePboardType, nil] owner:self];
    //[pboard setData:dragData forType:ALBUMIMAGEDATATYPE];
    
    
    NSRect itemRect;
    NSImage *dragImage = [self imageForCurrentSelectionWithItemRect:&itemRect];
    
    [super dragImage:dragImage
                  at:NSMakePoint(NSMinX(itemRect), NSMaxY(itemRect))
              offset:NSMakeSize(0, 0)
               event:theEvent
          pasteboard:pboard
              source:self
           slideBack:YES];
}


- (void)draggedImage:(NSImage *)anImage beganAt:(NSPoint)aPoint
{
}

- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation
{
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
  if ([delegate respondsToSelector:@selector(collectionView:draggingEntered:)])
    return [delegate collectionView:self draggingEntered:sender];
  else
    return [self draggingUpdated:sender];
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
  if (dragHoverIndex != NSNotFound)
    [self setNeedsDisplayInRect:[layoutManager rectOfItemAtIndex:dragHoverIndex]];
  
  NSPoint mouse    = [self convertPoint:[sender draggingLocation] fromView:nil];
  NSUInteger index = [layoutManager indexOfItemAtPoint:mouse];
  
  NSDragOperation operation = NSDragOperationNone;
  if ([sender draggingSource] == self) {
    if ([selectionIndexes containsIndex:index])
      [self setDragHoverIndex:NSNotFound];
    else if ([self delegateCanDrop:sender onIndex:index]) {
      [self setDragHoverIndex:index];
      operation = NSDragOperationMove;
    } else
      [self setDragHoverIndex:NSNotFound]; 
  } else {
    if ([self delegateCanDrop:sender onIndex:index]) {
      [self setDragHoverIndex:index];
      operation = NSDragOperationCopy;
    }
  }
  
  if (dragHoverIndex != NSNotFound)
    [self setNeedsDisplayInRect:[layoutManager rectOfItemAtIndex:dragHoverIndex]];
  
  return operation;
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender
{
  if (dragHoverIndex != NSNotFound)
    [self setNeedsDisplayInRect:[layoutManager rectOfItemAtIndex:dragHoverIndex]];
  
  [self setDragHoverIndex:NSNotFound];
  
  if ([delegate respondsToSelector:@selector(collectionView:draggingEnded:)])
    [delegate collectionView:self draggingEnded:sender];
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
  NSPoint mouse    = [self convertPoint:[sender draggingLocation] fromView:nil];
  NSUInteger index = [layoutManager indexOfItemAtPoint:mouse];
  
  if (index == NSNotFound) {
    [self setNeedsDisplayInRect:[layoutManager rectOfItemAtIndex:dragHoverIndex]];
    [self setDragHoverIndex:NSNotFound];
    
    if ([delegate respondsToSelector:@selector(collectionView:draggingExited:)])
      [delegate collectionView:self draggingExited:sender];
  }
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
  id item = nil;
  if (dragHoverIndex <[contentArray count])
    item = [contentArray objectAtIndex:dragHoverIndex];
  
  if ([delegate respondsToSelector:@selector(collectionView:performDragOperation:onViewController:forItem:)])
    return [delegate collectionView:self performDragOperation:sender onViewController:[self viewControllerForItemAtIndex:dragHoverIndex] forItem:item];
  else
    return NO;
}

#pragma mark -
#pragma mark Delegate Shortcuts

- (void)setDragHoverIndex:(NSUInteger)hoverIndex
{
  if (hoverIndex != dragHoverIndex) {
    if (dragHoverIndex != NSNotFound)
      [self setNeedsDisplayInRect:[layoutManager rectOfItemAtIndex:dragHoverIndex]];
    
    if ([delegate respondsToSelector:@selector(collectionView:dragExitedViewController:)])
      [delegate collectionView:self dragExitedViewController:[self viewControllerForItemAtIndex:dragHoverIndex]];
    
    dragHoverIndex = hoverIndex;
    
    if ([delegate respondsToSelector:@selector(collectionView:dragEnteredViewController:)])
      [delegate collectionView:self dragEnteredViewController:[self viewControllerForItemAtIndex:dragHoverIndex]];
    
    if (dragHoverIndex != NSNotFound)
      [self setNeedsDisplayInRect:[layoutManager rectOfItemAtIndex:dragHoverIndex]];
  }
}

- (BOOL)delegateSupportsDragForItemsAtIndexes:(NSIndexSet *)indexSet
{
  if ([delegate respondsToSelector:@selector(collectionView:canDragItemsAtIndexes:)])
    return [delegate collectionView:self canDragItemsAtIndexes:indexSet];
  return NO;
}

- (void)delegateWriteIndexes:(NSIndexSet *)indexSet toPasteboard:(NSPasteboard *)pasteboard
{
  if ([delegate respondsToSelector:@selector(collectionView:writeItemsAtIndexes:toPasteboard:)])
    [delegate collectionView:self writeItemsAtIndexes:indexSet toPasteboard:pasteboard];
}

- (BOOL)delegateCanDrop:(id)draggingInfo onIndex:(NSUInteger)index
{
  if ([delegate respondsToSelector:@selector(collectionView:validateDrop:onItemAtIndex:)])
    return [delegate collectionView:self validateDrop:draggingInfo onItemAtIndex:index];
  else
    return NO;
}

@end
