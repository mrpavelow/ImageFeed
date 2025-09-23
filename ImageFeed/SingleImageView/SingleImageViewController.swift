import UIKit
import Kingfisher
import ProgressHUD

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            updateImage(image)
        }
    }
    
    var fullImageURL: URL?
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        if let image {
            updateImage(image)
        } else if let url = fullImageURL {
            loadImage(from: url)
        }
    }
    
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton() {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(share, animated: true, completion: nil)
    }
}

private extension SingleImageViewController {
    func updateImage(_ image: UIImage) {
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    func loadImage(from url: URL) {
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(
            with: url,
            options: [.transition(.fade(0.25))]
        ) { [weak self] result in
            switch result {
            case .success(let value):
                self?.updateImage(value.image)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                print("Ошибка загрузки изображения: \(error)")
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func centerImage() {
        guard let imageView = scrollView.subviews.first as? UIImageView else { return }

        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size

        let verticalInset = max(0, (scrollViewSize.height - imageViewSize.height) / 2)
        let horizontalInset = max(0, (scrollViewSize.width - imageViewSize.width) / 2)

        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        centerImage()
        return imageView
    }
}
