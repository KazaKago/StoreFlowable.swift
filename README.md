# StoreFlowable.swift

[![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/kazakago/storeflowable.swift.svg)](https://github.com/KazaKago/StoreFlowable.swift/releases/latest)
[![Test](https://github.com/KazaKago/StoreFlowable.swift/workflows/Test/badge.svg)](https://github.com/KazaKago/StoreFlowable.swift/actions?query=workflow%3ATest)
[![License](https://img.shields.io/github/license/kazakago/storeflowable.swift.svg)](LICENSE)

[Repository pattern](https://msdn.microsoft.com/en-us/library/ff649690.aspx) support library for Swift with Combine Framework.  
Available for iOS or any Mac/tvOS/watchOS projects.  

## Overview

This library provides remote and local data abstraction and observation with [Combine Framework](https://developer.apple.com/documentation/combine).  
Created according to the following 5 policies.  

- **Repository pattern**
    - Abstract remote and local data acquisition.
- **Single Source of Truth**
    - Looks like a single source from the user side.
- **Observer pattern**
    - Observing data with Combine Framework.
- **Return value as soon as possible**
- **Representing the state of data**

The following is the class structure of Repository pattern using this library.  

![https://user-images.githubusercontent.com/7742104/126891014-ce95b223-5b13-4290-8b58-faf1dcebf49e.jpg](https://user-images.githubusercontent.com/7742104/126891014-ce95b223-5b13-4290-8b58-faf1dcebf49e.jpg)

The following is an example of screen display using [`LoadingState`](Sources/StoreFlowable/Core/LoadingState.swift).  

![https://user-images.githubusercontent.com/7742104/125714730-381eee65-4126-4ee8-991a-7fc64dfb325c.jpg](https://user-images.githubusercontent.com/7742104/125714730-381eee65-4126-4ee8-991a-7fc64dfb325c.jpg)

## Requirement

- iOS 13.0 or later
- MacOS 10.15 or later
- tvOS 13.0 or later
- watchOS 6.0 or later

## Install

Install as [Swift Package Manager](https://swift.org/package-manager/) exchanging x.x.x for the latest tag.  

```swift
dependencies: [
    .package(url: "https://github.com/KazaKago/StoreFlowable.swift.git", from: "x.x.x"),
],
```

## Basic Usage

There are only 5 things you have to implement:  

- Create data state management class
- Get data from local cache
- Save data to local cache
- Get data from remote server
- Whether the cache is valid

### 1. Create FlowableDataStateManager class

First, create a class that inherits [`FlowableDataStateManager<KEY: Hashable>`](Sources/StoreFlowable/FlowableDataStateManager.swift).  
Put the type you want to use as a key in `<KEY: Hashable>`. If you don't need the key, put in the [`UnitHash`](Sources/StoreFlowable/UnitHash.swift).  

```swift
class UserStateManager: FlowableDataStateManager<UserId> {
    static let shared = UserStateManager()
    private override init() {}
}
```

[`FlowableDataStateManager<KEY: Hashable>`](Sources/StoreFlowable/FlowableDataStateManager.swift) needs to be used in Singleton pattern.  

### 2. Create StoreFlowableFactory class

Next, create a class that implements [`StoreFlowableFactory`](Sources/StoreFlowable/StoreFlowableFactory.swift).  
Put the type you want to use as a Data in `DATA` associatedtype.  

An example is shown below.  

```swift
struct UserFlowableFactory : StoreFlowableFactory {

    typealias KEY = UserId
    typealias DATA = UserData

    private let userApi = UserApi()
    private let userCache = UserCache()

    init(userId: UserId) {
        key = userId
    }

    // Set the key for input / output of data. If you don't need the key, put in the UnitHash.
    let key: UserId

    // Create data state management class.
    let flowableDataStateManager: FlowableDataStateManager<UserId> = UserStateManager.shared

    // Get data from local cache.
    func loadDataFromCache() -> AnyPublisher<UserData?, Never> {
        userCache.load(userId: key)
    }

    // Save data to local cache.
    func saveDataToCache(newData: UserData?) -> AnyPublisher<Void, Never> {
        userCache.save(userId: key, data: newData)
    }

    // Get data from remote server.
    func fetchDataFromOrigin() -> AnyPublisher<UserData, Error> {
        userApi.fetch(userId: key)
    }

    // Whether the cache is valid.
    func needRefresh(cachedData: UserData) -> AnyPublisher<Bool, Never> {
        cachedData.isExpired()
    }
}
```

You need to prepare the API access class and the cache access class.  
In this case, `UserApi` and `UserCache` classes.  

### 3. Create Repository class

After that, you can get the [`AnyStoreFlowable<KEY: Hashable, DATA>`](Sources/StoreFlowable/AnyStoreFlowable.swift) class from the [`StoreFlowableFactory.create()`](Sources/StoreFlowable/StoreFlowableExtension.swift) method, and use it to build the Repository class.  
Be sure to go through the created [`AnyStoreFlowable<KEY: Hashable, DATA>`](Sources/StoreFlowable/AnyStoreFlowable.swift) class when getting / updating data.  

```swift
struct UserRepository {

    func followUserData(userId: UserId) -> LoadingStatePublisher<UserData> {
        let userFlowable: AnyStoreFlowable<UserId, UserData> = UserFlowableFactory(userId: userId).create()
        return userFlowable.publish()
    }

    func updateUserData(userData: UserData) -> AnyPublisher<Void, Never> {
        let userFlowable: AnyStoreFlowable<UserId, UserData> = UserFlowableFactory(userId: userId).create()
        return userFlowable.update(newData: userData)
    }
}
```

You can get the data in the form of [`LoadingStatePublisher<DATA>`](Sources/StoreFlowable/Core/LoadingStatePublisher.swift) (Same as `AnyPublisher<LoadingState<DATA>, Never>`) by using the [`publish()`](Sources/StoreFlowable/StoreFlowable.swift) method.  
[`LoadingState`](Sources/StoreFlowable/Core/LoadingState.swift) is a [enum](https://docs.swift.org/swift-book/LanguageGuide/Enumerations.html) that holds raw data.  

### 4. Use Repository class

You can observe the data by sink [`AnyPublisher`](https://developer.apple.com/documentation/combine).  
and branch the data state with [`doAction()`](Sources/StoreFlowable/Core/LoadingState.swift) method or `switch` statement.  

```swift
private func subscribe(userId: UserId) {
    userRepository.followUserData(userId: userId)
        .receive(on: DispatchQueue.main)
        .sink { state in
            state.doAction(
                onLoading: { (content: UserData?) in
                    ...
                },
                onCompleted: { (content: UserData, _, _) in
                    ...
                },
                onError: { (error: Error) in
                    ...
                }
            )
        }
        .store(in: &cancellableSet)
}

```

## Example

Refer to the [**example project**](Example) for details. This module works as an iOS app.  
See [GithubMetaFlowableFactory](Example/Example/Flowable/GithubMetaFlowableFactory.swift) and [GithubUserFlowableFactory](Example/Example/Flowable/GithubUserFlowableFactory.swift).  

This example accesses the [Github API](https://docs.github.com/en/free-pro-team@latest/rest).  

## Advanced Usage

### Get data without [LoadingState](Sources/StoreFlowable/Core/LoadingState.swift) enum

If you don't need value flow and [`LoadingState`](Sources/StoreFlowable/Core/LoadingState.swift) enum, you can use [`requireData()`](Sources/StoreFlowable/StoreFlowable.swift) or [`getData()`](Sources/StoreFlowable/StoreFlowable.swift).  
[`requireData()`](Sources/StoreFlowable/StoreFlowable.swift) throws an Error if there is no valid cache and fails to get new data.  
[`getData()`](Sources/StoreFlowable/StoreFlowable.swift) returns nil instead of Error.  

```swift
public extension StoreFlowable {
    func getData(from: GettingFrom = .both) -> AnyPublisher<DATA?, Never>
    func requireData(from: GettingFrom = .both) -> AnyPublisher<DATA, Error>
}
```

[`GettingFrom`](Sources/StoreFlowable/GettingFrom.swift) parameter specifies where to get the data.  

```swift
public enum GettingFrom {
    // Gets a combination of valid cache and remote. (Default behavior)
    case both
    // Gets only remotely.
    case origin
    // Gets only locally.
    case cache
}
```

However, use [`requireData()`](Sources/StoreFlowable/StoreFlowable.swift) or [`getData()`](Sources/StoreFlowable/StoreFlowable.swift) only for one-shot data acquisition, and consider using [`publish()`](Sources/StoreFlowable/StoreFlowable.swift) if possible.  

### Refresh data

If you want to ignore the cache and get new data, add `forceRefresh` parameter to [`publish()`](Sources/StoreFlowable/StoreFlowable.swift).  

```swift
public extension StoreFlowable {
    func publish(forceRefresh: Bool = false) -> LoadingStatePublisher<DATA>
}
```

Or you can use [`refresh()`](Sources/StoreFlowable/StoreFlowable.swift) if you are already observing the `Publisher`.  

```swift
public protocol StoreFlowable {
    func refresh() -> AnyPublisher<Void, Never>
}
```

### Validate cache data

Use [`validate()`](Sources/StoreFlowable/StoreFlowable.swift) if you want to verify that the local cache is valid.  
If invalid, get new data remotely.  

```swift
public protocol StoreFlowable {
    func validate() -> AnyPublisher<Void, Never>
}
```

### Update cache data

If you want to update the local cache, use the [`update()`](Sources/StoreFlowable/StoreFlowable.swift) method.  
`Publisher` observers will be notified.  

```swift
public protocol StoreFlowable {
    func update(newData: DATA?) -> AnyPublisher<Void, Never>
}
```

## Pagination support

This library includes Pagination support.  

<img src="https://user-images.githubusercontent.com/7742104/103469914-7a833700-4dae-11eb-8ff8-98de478f20f8.gif" width="280"> <img src="https://user-images.githubusercontent.com/7742104/103469911-75be8300-4dae-11eb-924e-af509abd273a.gif" width="280">

Inherit [`PagnatingStoreFlowableFactory<KEY: Hashable, DATA>`](Sources/StoreFlowable/Pagination/PaginatingStoreFlowableFactory.swift) instead of [`StoreFlowableFactory<KEY: Hashable, DATA>`](Sources/StoreFlowable/StoreFlowableFactory.swift).  

An example is shown below.  

```swift
class UserListStateManager: FlowableDataStateManager<UnitHash> {
    static let shared = UserListStateManager()
    private override init() {}
}
```
```swift
struct UserListFlowableFactory : PaginationStoreFlowableFactory {

    typealias KEY = UnitHash
    typealias DATA = [UserData]

    private let userListApi = UserListApi()
    private let userListCache = UserListCache()

    let key: UnitHash = UnitHash()

    let flowableDataStateManager: FlowableDataStateManager<UnitHash> = UserListStateManager.shared

    func loadDataFromCache() -> AnyPublisher<[UserData]?, Never> {
        userListCache.load()
    }

    func saveDataToCache(newData: [UserData]?) -> AnyPublisher<Void, Never> {
        userListCache.save(data: newData)
    }

    func saveNextDataToCache(cachedData: [UserData], newData: [UserData]) -> AnyPublisher<Void, Never> {
        userListCache.save(data: cachedData + newData)
    }

    func fetchDataFromOrigin() -> AnyPublisher<Fetched<[UserData]>, Error> {
        let fetchedData = userListApi.fetch(page: nil)
        return Fetched(data: data, nextKey: fetchedData.nextToken)
    }

    func fetchNextDataFromOrigin(nextKey: String) -> AnyPublisher<Fetched<[UserData]>, Error> {
        return userListApi.fetch(page: page).map { data in
            FetchingResult(data: data, nextKey: fetchedData.nextToken)
        }.eraseToAnyPublisher()
    }

    func needRefresh(cachedData: [UserData]) -> AnyPublisher<Bool, Never> {
        cachedData.last.isExpired()
    }
}
```

You need to additionally implements [`saveNextDataToCache()`](Sources/StoreFlowable/Pagination/OneWay/PaginationStoreFlowableFactory.swift) and [`fetchNextDataFromOrigin()`](Sources/StoreFlowable/Pagination/OneWay/PaginationStoreFlowable.swift).  
When saving the data, combine the cached data and the new data before saving.  

The [GithubOrgsFlowableFactory](Example/Example/Flowable/GithubOrgsFlowableFactory.swift) and [GithubReposFlowableFactory](Example/Example/Flowable/GithubReposFlowableFactory.swift) classes in [**example project**](Example) implement pagination.  

### Request additional data

You can request additional data for paginating using the [`requestNextData()`](Sources/StoreFlowable/Pagination/OneWay/PaginationStoreFlowable.swift) method.  

```swift
public extension PaginationStoreFlowable {
    func requestNextData(continueWhenError: Bool = true) -> AnyPublisher<Void, Never>
}
```

## License

This project is licensed under the **Apache-2.0 License** - see the [LICENSE](LICENSE) file for details.  
