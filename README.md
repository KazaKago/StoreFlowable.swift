# StoreFlowable.swift

![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/kazakago/storeflowable.swift)
[![Test](https://github.com/KazaKago/StoreFlowable.swift/workflows/Test/badge.svg)](https://github.com/KazaKago/StoreFlowable.swift/actions?query=workflow%3ATest)
[![license](https://img.shields.io/github/license/kazakago/storeflowable.swift.svg)](LICENSE)

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

![https://user-images.githubusercontent.com/7742104/103459433-bc7e8f80-4d52-11eb-8c3d-c885d76565fc.jpg](https://user-images.githubusercontent.com/7742104/103459433-bc7e8f80-4d52-11eb-8c3d-c885d76565fc.jpg)

The following is an example of screen display using [`State`](Sources/StoreFlowable/Core/State.swift).

![https://user-images.githubusercontent.com/7742104/103459431-bab4cc00-4d52-11eb-983a-2087dd3100a0.jpg](https://user-images.githubusercontent.com/7742104/103459431-bab4cc00-4d52-11eb-983a-2087dd3100a0.jpg)

## Requirement

- iOS 14 or later
- MacOS 11 or later
- tvOS 14 or later
- watchOS 7 or later

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

### 2. Create StoreFlowableResponder class

Next, create a class that implements [`StoreFlowableResponder`](Sources/StoreFlowable/StoreFlowableResponder.swift).
Put the type you want to use as a Data in `DATA` associatedtype.  

An example is shown below.  

```swift
struct UserResponder : StoreFlowableResponder {

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
    func loadData() -> AnyPublisher<UserData?, Never> {
        userCache.load(userId: key)
    }

    // Save data to local cache.
    func saveData(data: UserData?) -> AnyPublisher<Void, Never> {
        userCache.save(userId: key, data: data)
    }

    // Get data from remote server.
    func fetchOrigin() -> AnyPublisher<UserData, Error> {
        userApi.fetch(userId: key)
    }

    // Whether the cache is valid.
    func needRefresh(data: UserData) -> AnyPublisher<Bool, Never> {
        data.isExpired()
    }
}
```

You need to prepare the API access class and the cache access class.  
In this case, `UserApi` and `UserCache` classes.  

### 3. Create Repository class

After that, you can get the [`AnyStoreFlowable<KEY: Hashable, DATA>`](Sources/StoreFlowable/AnyStoreFlowable.swift) class from the [`StoreFlowableResponder.create()`](Sources/StoreFlowable/StoreFlowableExtension.swift) method, and use it to build the Repository class.  
Be sure to go through the created [`AnyStoreFlowable<KEY: Hashable, DATA>`](Sources/StoreFlowable/AnyStoreFlowable.swift) class when getting / updating data.  

```swift
struct UserRepository {

    func followUserData(userId: UserId) -> AnyPublisher<State<UserData>, Never> {
        let userFlowable: AnyStoreFlowable<UserId, UserData> = UserResponder(userId: userId).create()
        return userFlowable.publish()
    }

    func updateUserData(userData: UserData) -> AnyPublisher<Void, Never> {
        let userFlowable: AnyStoreFlowable<UserId, UserData> = UserResponder(userId: userId).create()
        return userFlowable.update(newData: userData)
    }
}
```

You can get the data in the form of `AnyPublisher<State<DATA>, Never>` by using the [`publish()`](Sources/StoreFlowable/StoreFlowable.swift) method.  
[`State`](Sources/StoreFlowable/Core/State.swift) is a [enum](https://docs.swift.org/swift-book/LanguageGuide/Enumerations.html) that holds raw data.

### 4. Use Repository class

You can observe the data by sink [`AnyPublisher<State<Data>, Never>`](https://developer.apple.com/documentation/combine).  
and branch the data state with `doAction()` method or `switch` statement.  

```swift
private func subscribe(userId: UserId) {
    userRepository.followUserData(userId: userId)
        .receive(on: DispatchQueue.main)
        .sink { state in
            state.doAction(
                onFixed: {
                    state.content.doAction(
                        onExist: { value in
                            ...
                        },
                        onNotExist: {
                            ...
                        }
                    )
                },
                onLoading: {
                    state.content.doAction(
                        onExist: { value in
                            ...
                        },
                        onNotExist: {
                            ...
                        }
                    )
                },
                onError: { error in
                    state.content.doAction(
                        onExist: { value in
                            ...
                        },
                        onNotExist: {
                            ...
                        }
                    )
                }
            )
        }
        .store(in: &cancellableSet)
}

```

## Example

Refer to the [**sample project**](Sample) for details. This module works as an iOS app.  
See [GithubMetaResponder](Sample/Sample/Flowable/GithubMetaResponder.swift) and [GithubUserResponder](Sample/Sample/Flowable/GithubUserResponder.swift).

This example accesses the [Github API](https://docs.github.com/en/free-pro-team@latest/rest).  

## Advanced Usage

### Get data without [State](Sources/StoreFlowable/Core/State.swift) enum

If you don't need value flow and [`State`](Sources/StoreFlowable/Core/State.swift) enum, you can use [`get()`](Sources/StoreFlowable/StoreFlowable.swift) or [`getOrNil()`](Sources/StoreFlowable/StoreFlowableExtension.swift).  
[`get()`](Sources/StoreFlowable/StoreFlowable.swift) throws an Error if there is no valid cache and fails to get new data.  
[`getOrNil()`](Sources/StoreFlowable/StoreFlowableExtension.swift) returns nil instead of Error.  

```swift
public extension StoreFlowable {
    func get(type: AsDataType = .mix) -> AnyPublisher<DATA, Error>
}
```

`AsDataType` parameter specifies where to get the data.  

```swift
public enum AsDataType {
    // Gets a combination of valid cache and remote. (Default behavior)
    case mix
    // Gets only remotely.
    case fromOrigin
    // Gets only locally.
    case fromCache
}
```

However, use [`get()`](Sources/StoreFlowable/StoreFlowable.swift) or [`getOrNil()`](Sources/StoreFlowable/StoreFlowableExtension.swift) only for one-shot data acquisition, and consider using [`publish()`](Sources/StoreFlowable/StoreFlowable.swift) if possible.  

### Refresh data

If you want to ignore the cache and get new data, add `forceRefresh` parameter to [`publish()`](Sources/StoreFlowable/StoreFlowable.swift).  

```swift
public extension StoreFlowable {
    func publish(forceRefresh: Bool = false) -> AnyPublisher<State<DATA>, Never>
}
```

Or you can use [`refresh()`](Sources/StoreFlowable/StoreFlowable.swift) if you are already observing the `Publisher`.  

```swift
public extension StoreFlowable {
    func refresh(clearCacheWhenFetchFails: Bool = true, continueWhenError: Bool = true) -> AnyPublisher<Void, Never>
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

### Paging support

This library includes Paging support.  

<img src="https://user-images.githubusercontent.com/7742104/103469914-7a833700-4dae-11eb-8ff8-98de478f20f8.gif" width="280"> <img src="https://user-images.githubusercontent.com/7742104/103469911-75be8300-4dae-11eb-924e-af509abd273a.gif" width="280">

Inherit [`PagingStoreFlowableResponder<KEY: Hashable, DATA>`](Sources/StoreFlowable/Paging/PagingStoreFlowable.swift) instead of [`StoreFlowableResponder<KEY: Hashable, DATA>`](Sources/StoreFlowable/StoreFlowableResponder.swift).

An example is shown below.  

```swift
class UserListStateManager: FlowableDataStateManager<UnitHash> {
    static let shared = UserListStateManager()
    private override init() {}
}
```
```swift
struct UserListResponder : PagingStoreFlowableResponder {

    typealias KEY = UnitHash
    typealias DATA = UserData

    private let userListApi = UserListApi()
    private let userListCache = UserListCache()

    let key: UnitHash = UnitHash()

    let flowableDataStateManager: FlowableDataStateManager<UnitHash> = UserListStateManager.shared

    func loadData() -> AnyPublisher<[UserData]?, Never> {
        userListCache.load()
    }

    func saveData(data: [UserData]?, additionalRequest: Bool) -> AnyPublisher<Void, Never> {
        userListCache.save(data: data)
    }

    func fetchOrigin(data: [UserData]?, additionalRequest: Bool) -> AnyPublisher<[UserData], Error> {
        let page = additionalRequest ? ((data?.count ?? 0) / 10 + 1) : 1
        return userListApi.fetch(page: page)
    }

    func needRefresh(data: [UserData]) -> AnyPublisher<Bool, Never> {
        data.last.isExpired()
    }
}
```

You can have the data in a list. The retrieved remote data will be merged automatically.  
`additionalRequest: Bool` parameter indicates whether to load additionally. use if necessary.  

The [GithubOrgsResponder](Sample/Sample/Flowable/GithubOrgsResponder.swift) and [GithubReposResponder](Sample/Sample/Flowable/GithubReposResponder.swift) classes in [**sample project**](Sample) implement paging.

## License

This project is licensed under the **Apache-2.0 License** - see the [LICENSE](LICENSE) file for details.  
