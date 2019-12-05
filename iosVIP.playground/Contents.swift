import UIKit

var str = "Hello, playground"

class HomeView: UIViewController {
    
    var restaurantsList: RestaurantsList!
    var dishesList: DishesList!
    var menuFilter: MenuFilterView!

    var interactor = HomeInteractor()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        restaurantsList = segue.destination as? RestaurantsList
        restaurantsList.delegate = self
        restaurantsList.dataSource = RestaurantsListDataSource(restaurants: [])
        
        dishesList = segue.destination as? DishesList
        dishesList.dataSource = DishesListDataSource(dishes: [])
        dishesList.delegate = self
        
        menuFilter = segue.destination as? MenuFilterView
        menuFilter.delegate = self
        menuFilter.dataSource = MenuFilterDataSource(isOnline: true, category: "edh")

    }
}

extension HomeView: RestaurantsListDelegate {
    func didSelectRestaurant(restaurant: Restaurant) {
        interactor.didSelectRestaurant(restaurant: restaurant)
    }
}


extension HomeView: DishesListDelegate {
    func didSelectDish(dish: Dish) {
        interactor.didSelectDish(dish: dish)
    }
}

extension HomeView: MenuFilterDelegate {
    func didUpdateFilter(options: MenuFilterDataSource) {
        interactor.didUpdateFilter(options: options) // here we will send the business model "FilterOption" not the datasource

    }
}

extension HomeView: HomeViewProtocol {
    func updateRestaurantsList(_ restaurants: [RestaurantsListModel]) {
        restaurantsList.dataSource = RestaurantsListDataSource(restaurants: restaurants)
    }
}





class HomeInteractor {
    
    var presenter = HomePresenter()
    
    init() {
        do {
            let restaurants = try GetAllRestaurantsWorker().execute()
            self.presenter.updateRestaurantsList(restaurants)
        } catch let error {
            self.presenter.handleError(error)
        }
    }
    
    func didSelectRestaurant(restaurant: Restaurant) {
        presenter.navigateToRestaurantView()
    }
    
    func didSelectDish(dish: Dish) {
        do {
            let restaurants = try GetRestaurantsByDishWorker().execute()
            self.presenter.updateRestaurantsList(restaurants)
        } catch let error {
            self.presenter.handleError(error)
        }
    }
    
    func didUpdateFilter(options: MenuFilterDataSource) {
        do {
             let restaurants = try GetRestaurantsWithFilter().execute()
             self.presenter.updateRestaurantsList(restaurants)
         } catch let error {
             self.presenter.handleError(error)
         }
    }
}

class HomePresenter {
    
    var view: HomeViewProtocol!
    
    func navigateToRestaurantView() {
        // go to screen
    }
    
    func updateRestaurantsList(_ restaurants: [Restaurant]) {
        view.updateRestaurantsList(restaurants.map({RestaurantsListModel(restaurant: $0)}))
    }
    
    func handleError(_ error: Error) {
           // show error
    }
}

protocol HomeViewProtocol {
    func updateRestaurantsList(_ restaurants: [RestaurantsListModel])
}


class GetRestaurantsByDishWorker {
    
    func execute() throws -> [Restaurant] {
        return [Restaurant(title: "", desc: "s")]
    }
}

class GetAllRestaurantsWorker {
    
    func execute() throws -> [Restaurant] {
        return [Restaurant(title: "", desc: "s")]
    }
}

class GetRestaurantsWithFilter {
    
    func execute() throws -> [Restaurant] {
        return [Restaurant(title: "", desc: "s")]
    }
}








































class RestaurantsList: UITableViewController {
    
    var dataSource: RestaurantsListDataSource! // add didSet to reload table view
    var delegate: RestaurantsListDelegate!

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.restaurants.count
    }
    
    //cellforrow
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.didSelectRestaurant(restaurant: dataSource.restaurants[indexPath.row].toModel())
    }
}

protocol RestaurantsListDelegate {
    func didSelectRestaurant(restaurant: Restaurant)
}

struct RestaurantsListDataSource {
    var restaurants: [RestaurantsListModel]
}

struct RestaurantsListModel {
    
    let title: String
    let summary: String
    
    init(restaurant: Restaurant) {
        self.title = restaurant.title
        self.summary = "descr: ... " + restaurant.desc
    }
    
    func toModel() -> Restaurant {
        return Restaurant(title: title, desc: summary) //remove extra
    }
}

/////
class DishesList: UICollectionViewController {
    
    var dataSource: DishesListDataSource! // add didSet to reload collection view
    var delegate: DishesListDelegate!

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.dishes.count
    }
    
    //cellforrow
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.didSelectDish(dish: dataSource.dishes[indexPath.row].toModel())
    }
}

protocol DishesListDelegate {
    func didSelectDish(dish: Dish)
}

struct DishesListDataSource {
    var dishes: [DishesListModel]
}

struct DishesListModel {
    
    let title: String
    let date: String
    
    init(dish: Dish) {
        self.title = dish.title
        self.date = "" // dish.date.toString
    }
    
    func toModel() -> Dish {
        return Dish(title: title, date: Date())//toDate)
    }
}



////
class MenuFilterView: UIViewController {
    
    var dataSource: MenuFilterDataSource! // add didSet to reload collection view
    var delegate: MenuFilterDelegate!
    
    override func viewDidLoad() {
        // update outlets with datasource
    }
    
    func confirmUpdate() {
        delegate.didUpdateFilter(options: dataSource)
    }

}

protocol MenuFilterDelegate {
    func didUpdateFilter(options: MenuFilterDataSource)
}

struct MenuFilterDataSource {
    var isOnline: Bool
    var category: String
}


















struct Dish {
    let title: String
    let date: Date
}


struct Restaurant {
    let title: String
    let desc: String
}
