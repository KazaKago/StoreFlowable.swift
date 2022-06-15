# StoreFlowable.swift

[![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/kazakago/storeflowable.swift.svg)](https://github.com/KazaKago/StoreFlowable.swift/releases/latest)
[![Test](https://github.com/KazaKago/StoreFlowable.swift/workflows/Test/badge.svg)](https://github.com/KazaKago/StoreFlowable.swift/actions?query=workflow%3ATest)
[![License](https://img.shields.io/github/license/kazakago/storeflowable.swift.svg)](LICENSE)

[Repository pattern](https://msdn.microsoft.com/en-us/library/ff649690.aspx) support library for Swift with Concurrency.  
Available for iOS or any Swift projects.  

## Overview

This library provides remote and local cache abstraction and observation with [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html).  
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

## Install

Install as [Swift Package Manager](https://swift.org/package-manager/) exchanging x.x.x for the latest tag.  

```swift
dependencies: [
    .package(url: "https://github.com/KazaKago/StoreFlowable.swift.git", from: "x.x.x"),
],
```

## Get started

There are only 2 things you have to implement:  

- Create a class to manage the in-app cache.
- Create a class to get data from origin server.

### 1. Create a class to manage the in-app cache

First, create a class that inherits [`Cacher<PARAM: Hashable, DATA>`](Sources/StoreFlowable/cacher/Cacher.swift).  
Put the type you want to use as a param in `<PARAM: Hashable>`. If you don't need the param, put in the [`UnitHash`](Sources/StoreFlowable/UnitHash.swift).  

```swift
class UserCacher: Cacher<UserId, UserData> {
    static let shared = UserCacher()
    private override init() {}
}
```

[`Cacher<PARAM: Hashable, DATA>`](Sources/StoreFlowable/Cacher/Cacher.swift) needs to be used in Singleton pattern.  

### 2. Create a class to get data from origin server

Next, create a class that implements [`Fetcher`](Sources/StoreFlowable/Fetcher/Fetcher.swift).  
Put the type you want to use as a Data in `DATA` associatedtype.  

An example is shown below.  

```swift
struct UserFetcher : Fetcher {

    typealias PARAM = UserId
    typealias DATA = UserData

    private let userApi = UserApi()

    func fetch(param: UserId) async throws -> UserData {
        userApi.fetch(userId: param)
    }
}
```

You need to prepare the API access class.  
In this case, `UserApi` classe.  

### 3. Build StoreFlowable from Cacher & Fetcher class

After that, you can get the [`StoreFlowable<DATA>`](Sources/StoreFlowable/StoreFlowable.swift) class from the [`AnyStoreFlowable.from()`](Sources/StoreFlowable/StoreFlowableExtension.swift) method.  
Be sure to go through the created [`StoreFlowable<DATA>`](Sources/StoreFlowable/StoreFlowable.swift) class when getting / updating data.  

```swift
let userFlowable: AnyStoreFlowable<UserData> = AnyStoreFlowable.from(cacher: userCacher, fetcher: userFetcher, param: userId)
let userStateSequence: LoadingStateSequence<UserData> = userFlowable.publish()
```

You can get the data in the form of [`LoadingStateSequence<DATA>`](Sources/StoreFlowable/Core/LoadingStateSequence.swift) (Same as `AsyncSequence<LoadingState<DATA>>`) by using the [`publish()`](Sources/StoreFlowable/StoreFlowable.swift) method.  
[`LoadingState`](Sources/StoreFlowable/Core/LoadingState.swift) is a [enum](https://docs.swift.org/swift-book/LanguageGuide/Enumerations.html) that holds raw data.  

### 4. Subscribe `FlowLoadingState<DATA>`

You can observe the data by for-in [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence).  
and branch the data state with [`doAction()`](Sources/StoreFlowable/Core/LoadingState.swift) method or `switch` statement.  

```swift
for try await userState in userStateSequence {
    userState.doAction(
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
```

## Example

Refer to the [**example project**](Example) for details. This module works as an iOS app.  
See [GithubMetaFlowableFactory](Example/Example/Flowable/GithubMetaFlowableFactory.swift) and [GithubUserFlowableFactory](Example/Example/Flowable/GithubUserFlowableFactory.swift).  

Refer to the [**example module**](example) for details. This module works as an Android app.  
See [GithubMetaCacher](Example/Example/Cacher/GithubMetaCacher.swift) + [GithubMetaFetcher](Example/Example/Fetcher/GithubMetaFetcher.swift) or [GithubUserCacher](Example/Example/Cacher/GithubUserCacher.swift) + [GithubUserFetcher](Example/Example/Fetcher/GithubUserFetcher.swift).

This example accesses the [Github API](https://docs.github.com/en/free-pro-team@latest/rest).  

## Other usage of `StoreFlowable` class

### Get data without [LoadingState](Sources/StoreFlowable/Core/LoadingState.swift) enum

If you don't need value flow and [`LoadingState`](Sources/StoreFlowable/Core/LoadingState.swift) enum, you can use [`requireData()`](Sources/StoreFlowable/StoreFlowable.swift) or [`getData()`](Sources/StoreFlowable/StoreFlowable.swift).  
[`requireData()`](Sources/StoreFlowable/StoreFlowable.swift) throws an Error if there is no valid cache and fails to get new data.  
[`getData()`](Sources/StoreFlowable/StoreFlowable.swift) returns nil instead of Error.  

```swift
public extension StoreFlowable {
    func getData(from: GettingFrom = .both) async -> DATA?
    func requireData(from: GettingFrom = .both) async throws -> DATA
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
    func publish(forceRefresh: Bool = false) -> LoadingStateSequence<DATA>
}
```

Or you can use [`refresh()`](Sources/StoreFlowable/StoreFlowable.swift) if you are already observing the `Publisher`.  

```swift
public protocol StoreFlowable {
    func refresh() async
}
```

### Validate cache data

Use [`validate()`](Sources/StoreFlowable/StoreFlowable.swift) if you want to verify that the local cache is valid.  
If invalid, get new data remotely.  

```swift
public protocol StoreFlowable {
    func validate() async
}
```

### Update cache data

If you want to update the local cache, use the [`update()`](Sources/StoreFlowable/StoreFlowable.swift) method.  
`Publisher` observers will be notified.  

```swift
public protocol StoreFlowable {
    func update(newData: DATA?) async
}
```

## `LoadingStateSequence<DATA>` operators

### Map `LoadingStateSequence<DATA>`

Use [`mapContent(transform)`](Sources/StoreFlowable/Core/LoadingStateSequenceMapper.swift) to transform content in `LoadingStateSequence<DATA>`.

```swift
let state: LoadingStateSequence<Int> = ...
let mappedState: LoadingStateSequence<String> = state.mapContent { value: Int in
    value.toString()
}
```

### Combine multiple `LoadingStateSequence<DATA>`

Use [`combineState(state, transform)`](Sources/StoreFlowable/Core/LoadingStateSequenceCombiner.swift) to combine multiple `LoadingStateSequence<DATA>`.

```swift
let state1: LoadingStateSequence<Int> = ...
let state2: LoadingStateSequence<Int> = ...
let combinedState: LoadingStateSequence<Int> = state1.combineState(state2) { value1: Int, value2: Int in
    value1 + value2
}
```

## Manage Cache

### Manage cache expire time

You can easily set the cache expiration time. Override expireSeconds variable in your [`Cacher<PARAM: Hashable, DATA>`](Sources/StoreFlowable/Cacher/Cacher.swift) class.
The default value is `TimeInterval.infinity` (= will NOT expire).

```swift
class UserCacher: Cacher<UserId, UserData> {
    static let shared = UserCacher()
    private override init() {}

    override var expireSeconds: TimeInterval {
        get { TimeInterval(60 * 30) } // expiration time is 30 minutes.
    }
}
```

### Persist data

If you want to make the cached data persistent, override the method of your [`Cacher<PARAM: Hashable, DATA>`](Sources/StoreFlowable/Cacher/Cacher.swift) class.

```swift
class UserCacher: Cacher<UserId, UserData> {
    static let shared = UserCacher()
    private override init() {}

    override var expireSeconds: TimeInterval {
        get { TimeInterval(60 * 30) } // expiration time is 30 minutes.
    }

    // Save the data for each parameter in any store.
    override func saveData(data: GithubMeta?, param: UnitHash) async {
        ...
    }

    // Get the data from the store for each parameter.
    override func loadData(param: UnitHash) async -> GithubMeta? {
        ...
    }

    // Save the epoch time for each parameter to manage the expiration time.
    // If there is no expiration time, no override is needed.
    override func saveDataCachedAt(epochSeconds: Double, param: UnitHash) async {
        ...
    }

    // Get the date for managing the expiration time for each parameter.
    // If there is no expiration time, no override is needed.
    override func loadDataCachedAt(param: UnitHash) async -> Double? {
        ...
    }
}
```

## Pagination support

This library includes Pagination support.  

<img src="https://user-images.githubusercontent.com/7742104/103469914-7a833700-4dae-11eb-8ff8-98de478f20f8.gif" width="280"> <img src="https://user-images.githubusercontent.com/7742104/103469911-75be8300-4dae-11eb-924e-af509abd273a.gif" width="280">

Inherit [`PaginationCacher<PARAM: Hashable, DATA>`](Sources/StoreFlowable/Cacher/PaginationCacher.swift) & [`PaginationFetcher`](Sources/StoreFlowable/Fetcher/PaginationFetcher.swift) instead of [`Cacher<PARAM: Hashable, DATA>`](Sources/StoreFlowable/StoreFlowableFactory.swift) & [`Fetcher`](Sources/StoreFlowable/Fetcher/Fetcher.swift).  

An example is shown below.  

```swift
class UserListCacher: PaginationCacher<UnitHash, UserData> {
    static let shared = UserListCacher()
    private override init() {}
}

struct UserListFetcher : PaginationFetcher {

    typealias PARAM = UnitHash
    typealias DATA = UserData

    private let userListApi = UserListApi()

    func fetch(param: UnitHash) async throws -> PaginationFetcher.Result<UserData> {
        let fetched = userListApi.fetch(pageToken: nil)
        return PaginationFetcher.Result(data: fetched.data, nextKey: fetched.nextPageToken)
    }

    func fetchNext(nextKey: String, param: UnitHash) async throws -> PaginationFetcher.Result<UserData> {
        let fetched = userListApi.fetch(pageToken: nextKey)
        return PaginationFetcher.Result(data: fetched.data, nextKey: fetched.nextPageToken)
    }
}
```

You need to additionally implements [`fetchNext(nextKey: String, param: PARAM)`](Sources/StoreFlowable/Fetcher/PaginationFetcher.swift).  

And then, You can get the state of additional loading from the `next` parameter of `onCompleted {}`.

```swift
let userFlowable = AnyStoreFlowable.from(cacher: userListCacher, fetcher: userListFetcher)
for try await loadingState in userFlowable.publish() {
    loadingState.doAction(
        onLoading: { (content: UserData?) in
            // Whole (Initial) data loading.
        },
        onCompleted: { (content: UserData, next: AdditionalLoadingState, _) in
            // Whole (Initial) data loading completed.
            next.doAction(
                onFixed: { (canRequestAdditionalData: Bool) in
                    // No additional processing.
                },
                onLoading: {
                    // Additional data loading.
                },
                onError: { (error: Error) in
                    // Additional loading error.
                }
            )
        },
        onError: { (error: Error) in
            // Whole (Initial) data loading error.
        }
    )
}
```

To display in the [`UITableView`](https://developer.apple.com/documentation/uikit/uitableview), Please use the difference update function. See also [`UITableViewDiffableDataSource`](https://developer.apple.com/documentation/uikit/uitableviewdiffabledatasource).

### Request additional data

You can request additional data for paginating using the [`requestNextData()`](Sources/StoreFlowable/Pagination/OneWay/PaginationStoreFlowable.swift) method.  

```swift
public extension PaginationStoreFlowable {
    func requestNextData(continueWhenError: Bool = true) async
}
```

## Pagination Example

The [GithubOrgsCacher](Example/Example/Cacher/GithubOrgsCacher.swift) + [GithubOrgsFetcher](Example/Example/Fetcher/GithubOrgsFetcher.swift) or [GithubReposCacher](Example/Example/Cacher/GithubReposCacher.swift) + [GithubReposFetcher](Example/Example/Fetcher/GithubReposFetcher.swift) classes in [**example module**](Example) implement pagination.

## License

This project is licensed under the **Apache-2.0 License** - see the [LICENSE](LICENSE) file for details.  
