import UIKit

public class ListViewController: UITableViewController {
  /// All places we know about.
  ///
  /// Updating this will trigger `updateFilteredPlaces`.
  var allPlaces: [Place] = [] {
    didSet {
      updateFilteredPlaces()
    }
  }

  /// The places presented to the user.
  private var filteredPlaces: [Place] = [] {
    didSet {
      guard oldValue != filteredPlaces else { return }

      tableView.reloadSections([0], with: .automatic)
    }
  }

  /// The search controller that drives filtering places.
  ///
  /// Updating this controller's search bar will trigger `updateFilteredPlaces`.
  let searchController = UISearchController(searchResultsController: nil)

  public init() {
    super.init(nibName: nil, bundle: nil)

    title = NSLocalizedString("app_title", comment: "The title of the app.")
  }

  @available(*, unavailable)
  public required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: PlaceTableViewCell.reuseIdentifier)
    tableView.tableFooterView = UIView()

    definesPresentationContext = true

    navigationItem.hidesSearchBarWhenScrolling = false
    navigationItem.searchController = searchController

    searchController.hidesNavigationBarDuringPresentation = false
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchResultsUpdater = self
    searchController.searchBar.placeholder =  NSLocalizedString("filter_placeholder", comment: "A placeholder for the filter bar.")
    searchController.searchBar.searchBarStyle = .minimal
  }

  // I think this can be moved to viewWillLoad. This doesn't need to be fetched each time the view appears,
  // and especially not when we return from the `PlaceViewController`.
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    PlaceFetcher.loadPlacesWithImages { [weak self] places in
      self?.allPlaces = places
        .sorted { $0.name.lowercased() < $1.name.lowercased() }
    }
  }

  /// Updates `filteredPlaces` based on `allPlaces` and the current search bar contents.
  private func updateFilteredPlaces() {
    self.filteredPlaces = ListViewController.filterPlaces(places: allPlaces,
                                                          filter: searchController.searchBar.text)
  }
}

extension ListViewController {
  public override func tableView(_ tableView: UITableView,
                                 cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    precondition(indexPath.section == 0)

    let cell = tableView.dequeueReusableCell(
      withIdentifier: PlaceTableViewCell.reuseIdentifier,
      for: indexPath) as! PlaceTableViewCell

    let place = filteredPlaces[indexPath.row]
    cell.updateWithPlace(place)

    return cell
  }

  public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }

  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    precondition(section == 0)

    return filteredPlaces.count
  }
}

extension ListViewController {
  public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let place = filteredPlaces[indexPath.row]

    let placeViewController = PlaceViewController(place: place)

    show(placeViewController, sender: self)
  }
}

extension ListViewController: UISearchResultsUpdating {
  public func updateSearchResults(for searchController: UISearchController) {
    updateFilteredPlaces()
  }
}

extension ListViewController {
  /// Filters an array of `Place` structs based on whether they mention a given `String`.
  ///
  /// - Parameters:
  ///   - places: The list of places to filter.
  ///   - filter: The `String` the user is filtering by.
  ///
  /// - Returns: An array of `Place` structs filtered by `filter`.
  static func filterPlaces(places: [Place], filter: String?) -> [Place] {
    guard let filter = filter, !filter.isEmpty else {
      return places
    }

    return places
      .filter { $0.name.lowercased().contains(filter.lowercased()) }
      .sorted { $0.name < $1.name }
  }
}
