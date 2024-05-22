import XCTest

final class WarehouseUITests: XCTestCase {
    
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
        
        try super.tearDownWithError()
    }
    
    func testAuth() {
        let login = app.textFields["Логин"]
        login.typeText("test")
        
        let pass = app.secureTextFields["Пароль"]
        pass.tap()
        pass.typeText("123\n")
    }
    
    func testHomeTabNavigation() throws {
        let tabBar = app.tabBars.firstMatch

        let homeTab = tabBar.buttons["Главная"]
        XCTAssertTrue(homeTab.exists, "Кнопка 'Главная' должна существовать в таббаре")

        homeTab.tap()
    }
    
    func testQRTabNavigation() throws {
        let tabBar = app.tabBars.firstMatch

        let qrTab = tabBar.buttons["Сканер"]
        XCTAssertTrue(qrTab.exists, "Кнопка 'Сканер' должна существовать в таббаре")

        qrTab.tap()
    }
    
    func testProjectsList() {
        let button = app.buttons["UITest"]
        button.tap()
    }
    
    
    func testWarehousesList() {
        testProjectsList()
        let button = app.buttons["Большой"]
        button.tap()
    }
    
    func testWarehousesProducts() {
        testWarehousesList()
        let button = app.cells.staticTexts["Test"]
        button.tap()
    }
    
    func testSorting() throws {
        try testHomeTabNavigation()
        testWarehousesList()

        XCTAssertTrue(app.cells.firstMatch.staticTexts["Test"].exists, "Первый элемент должен иметь текст 'Test'")

        let sortButton = app.buttons["Сортировка"]
        XCTAssertTrue(sortButton.exists, "Кнопка 'Сортировка' должна существовать")
        sortButton.tap()

        let sortByNameButton = app.buttons["По имени, я..а"]
        XCTAssertTrue(sortByNameButton.exists, "Кнопка сортировки 'По имени, я..а' должна существовать")
        sortByNameButton.tap()

        XCTAssertTrue(app.cells.firstMatch.staticTexts["Продукт 999"].exists, "Первый элемент должен иметь текст 'Продукт 999' после сортировки")
    }

    
    func testProduct() {
        testWarehousesProducts()
        let descr = app.textFields["Наименование"]
        XCTAssertEqual(descr.value as? String, "Test")
        descr.tap()
        descr.typeText("Тестовое описание\n")
    }
}
