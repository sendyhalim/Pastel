//
//  PasteboardCollectionViewController.swift
//  Pastel
//
//  Created by Sendy Halim on 2/11/16.
//  Copyright © 2016 Sendy Halim. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa
import Swiftz

struct ItemCell {
  static let maxHeight: CGFloat = 185
  static let maxWidth: CGFloat = 364
  static let minHeight: CGFloat = 85
  static let height = adjustedHeight • heightForItem
}

func adjustedHeight(height: CGFloat) -> CGFloat {
  if height < ItemCell.minHeight {
    return ItemCell.minHeight
  }

  if height > ItemCell.maxHeight {
    return ItemCell.maxHeight
  }

  return height
}

func heightForItem(item: PasteboardItem) -> CGFloat {
  switch item {
  case .URL(let url):
    let font = NSFont.systemFontOfSize(13)
    return url.description.heightForString(font, width: ItemCell.maxWidth)

  case .Text(let text):
    let font = NSFont.systemFontOfSize(13)
    return text.heightForString(font, width: ItemCell.maxWidth)

  case .Image(let image):
    return image.size.height

  case .LocalFile(_, let item):
    return heightForItem(item)
  }
}

class PasteboardCollectionViewController: NSViewController {
  let textItemCellId = "TextItemCell"
  let imageItemCellId = "ImageItemCell"

  let disposeBag = DisposeBag()
  let viewModel = PasteboardListViewModel()

  @IBOutlet weak var collectionView: NSCollectionView!

  override func viewDidLoad() {
    viewModel.startPollingItems()

    viewModel
      .items()
      .driveNext(constantCall(collectionView.reloadData))
      .addDisposableTo(disposeBag)
  }
}


extension PasteboardCollectionViewController: NSCollectionViewDataSource {
  func collectionView(
    collectionView: NSCollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return viewModel.totalItems()
  }

  func collectionView(
    collectionView: NSCollectionView,
    itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath
  ) -> NSCollectionViewItem {
    let item = viewModel[indexPath.item]
    return cellForItem(item, atIndexPath: indexPath)
  }

  func cellForItem(
    item: PasteboardItem,
    atIndexPath indexPath: NSIndexPath
  ) -> PasteboardCollectionViewItem {
    switch item {
    case .URL(let url):
      let cell = collectionView.makeItemWithIdentifier(
        textItemCellId,
        forIndexPath: indexPath
      ) as! PasteboardCollectionViewItem
      cell.textField!.stringValue = url.description
      cell.textField!.toolTip = url.description
      return cell

    case .Text(let text):
      let cell = collectionView.makeItemWithIdentifier(
        textItemCellId,
        forIndexPath: indexPath
      ) as! PasteboardCollectionViewItem
      cell.textField!.stringValue = text
      cell.textField!.toolTip = text
      return cell

    case .Image(let image):
      let cell = collectionView.makeItemWithIdentifier(
        imageItemCellId,
        forIndexPath: indexPath
      ) as! PasteboardCollectionViewItem
      cell.imageView!.image = image
      return cell

    case .LocalFile(_, let _item):
      return cellForItem(_item, atIndexPath: indexPath)
    }
  }
}

extension PasteboardCollectionViewController: NSCollectionViewDelegateFlowLayout {
  func collectionView(
    collectionView: NSCollectionView,
    layout collectionViewLayout: NSCollectionViewLayout,
    sizeForItemAtIndexPath indexPath: NSIndexPath
  ) -> NSSize {
    return sizeForItem(viewModel[indexPath.item])
  }

  func sizeForItem(item: PasteboardItem) -> NSSize {
    let width = collectionView.frame.size.width
    return NSSize(width: width, height: ItemCell.height(item))
  }

  func collectionView(
    collectionView: NSCollectionView,
    didSelectItemsAtIndexPaths indexPaths: Set<NSIndexPath>
  ) {
    let index = indexPaths.first!.item
    viewModel.addItemToPasteboard(index)
  }
}
