import UIKit

public class PlaceTableViewCell: UITableViewCell {
  public static let reuseIdentifier = "PlaceTableViewCell"

  let stackView = UIStackView()

  let textStack = UIStackView()

  let nameLabel = UILabel()

  let addressLabel = UILabel()

  let infoStack = UIStackView()

  let starsView = StarsView()

  let reviewsLabel = UILabel()

  let priceLabel = UILabel()

  let previewImageView = UIImageView()

  /// Used to keep track of the current image fetching task.
  ///
  /// Changing this value will automatically cancel the currently running task, if it exists.
  var imageFetchingTask: URLSessionTask? {
    didSet {
      guard imageFetchingTask != oldValue else { return }

      oldValue?.cancel()
    }
  }

  internal override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)

    stackView.alignment = .center
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.translatesAutoresizingMaskIntoConstraints = false

    textStack.alignment = .leading
    textStack.axis = .vertical
    textStack.distribution = .equalSpacing
    textStack.spacing = 4
    textStack.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubview(textStack)

    nameLabel.font = .preferredFont(forTextStyle: .headline)
    nameLabel.adjustsFontForContentSizeCategory = true
    nameLabel.numberOfLines = 0
    textStack.addArrangedSubview(nameLabel)

    addressLabel.font = .preferredFont(forTextStyle: .caption1)
    addressLabel.adjustsFontForContentSizeCategory = true
    addressLabel.numberOfLines = 0
    textStack.addArrangedSubview(addressLabel)

    infoStack.alignment = .center
    infoStack.spacing = 4
    textStack.addArrangedSubview(infoStack)

    infoStack.addArrangedSubview(starsView)

    reviewsLabel.font = .preferredFont(forTextStyle: .caption2)
    reviewsLabel.adjustsFontForContentSizeCategory = true
    infoStack.addArrangedSubview(reviewsLabel)

    priceLabel.font = .preferredFont(forTextStyle: .caption2)
    priceLabel.adjustsFontForContentSizeCategory = true
    infoStack.addArrangedSubview(priceLabel)

    previewImageView.contentMode = .scaleAspectFit
    previewImageView.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubview(previewImageView)

    contentView.addSubview(stackView)

    let heightConstraint = previewImageView.heightAnchor.constraint(equalToConstant: 80)
    heightConstraint.priority = UILayoutPriority(900)

    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
      stackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

      previewImageView.widthAnchor.constraint(equalToConstant: 124),
      heightConstraint,
    ])
  }

  @available(*, unavailable)
  internal required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Updates the receiver with the data of a given place.
  public func updateWithPlace(_ place: Place) {
    nameLabel.text = place.name
    addressLabel.text = place.address
    starsView.rating = place.stars
    reviewsLabel.text = "(\(place.reviews))"
    priceLabel.text = place.price

    guard let url = place.imageURL else { return }

    imageFetchingTask = ImageLoader.loadImage(forURL: url) { [weak self] image in
      self?.previewImageView.image = image
    }
  }

  public override func prepareForReuse() {
    super.prepareForReuse()

    imageFetchingTask = nil
  }
}
