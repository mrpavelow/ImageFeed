import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBAction private func likeButtonDidTap(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellImage.contentMode = .scaleAspectFill
        cellImage.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        dateLabel.text = nil
        likeButton.setImage(nil, for: .normal)
    }
    
    func setIsLiked(_ isLiked: Bool) {
       let imageResource: ImageResource = isLiked ? .activeLikeButton : .disableLikeButton
       likeButton.setImage(UIImage(resource: imageResource), for: .normal)
    }
    
    func setLikeButtonEnabled(_ isEnabled: Bool) {
        likeButton.isEnabled = isEnabled
    }
    
}
