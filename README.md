# ProgImage Store
**NOTE: This rails project is the solution for the [backend challenge of BCG DV](/docs/BCG-DVBackEndChallenge.pdf)**

ProgImage Store is a RubyOnRails service which provides simple APIs for
uploading images, downloading in JSON/HTML mode and make different types of conversion on the images defering the conversion to the moment the image is requested.

## DB Setup
The project assume that you have PostgreSQL DB server up and running in you machine. For creating the DBs and migrations:

```
$ bin/rake db:setup
Created database 'progimage_store_development'
Created database 'progimage_store_test'
$ bin/rake db:migrate
```

## UpAndRunning
First run bundle to download all the dependencies for the project:
```
$ bundle install
```

Then navigate to the project folder and boot the server as usual:
```
$ bin/rails server
=> Booting Puma
=> Rails 6.0.2.1 application starting in development
=> Run `rails server --help` for more startup options
Puma starting in single mode...
* Version 4.3.1 (ruby 2.6.5-p114), codename: Mysterious Traveller
* Min threads: 5, max threads: 5
* Environment: development
* Listening on tcp://127.0.0.1:3001
* Listening on tcp://[::1]:3001
Use Ctrl-C to stop
```

## Docker
In case you want to run the app with docker in production mode, you can build the image and use the `docker-compose.yml` config to run it locally. Inside `./docker/progimage_store.dev.env` you'll find for related config for running the docker image, change it as required (DB connection, ports, etc.).

Building the image:
```
$ docker build . -t progimage_store
Sending build context to Docker daemon  256.5kB
Step 1/12 : FROM ruby:2.6.5
 ---> dcb28425fa35
Step 2/12 : RUN apt-get update -qq &&   apt-get install -y imagemagick postgresql-client
 ---> Using cache
 ---> 6b6630ee5f52
Step 3/12 : RUN mkdir /progimage_store
 ---> Using cache
 ---> d4c49f56026a
Step 4/12 : WORKDIR /progimage_store
 ---> Using cache
 ---> 7b327b5c3a60
Step 5/12 : COPY Gemfile /progimage_store/Gemfile
 ---> Using cache
 ---> 2b147f86f2db
Step 6/12 : COPY Gemfile.lock /progimage_store/Gemfile.lock
 ---> Using cache
 ---> 7a036245572a
Step 7/12 : RUN bundle install --binstubs
 ---> Using cache
 ---> 700d2e748437
Step 8/12 : COPY . /progimage_store
 ---> 5895c4f91a7e
Step 9/12 : COPY docker/entrypoint.sh /usr/bin/
 ---> 4bfaa45e0a86
Step 10/12 : RUN chmod +x /usr/bin/entrypoint.sh
 ---> Running in 118267469b97
Removing intermediate container 118267469b97
 ---> 0ce40b4edf86
Step 11/12 : ENTRYPOINT ["entrypoint.sh"]
 ---> Running in 7377d6e7c368
Removing intermediate container 7377d6e7c368
 ---> a3a09f58c4cd
Step 12/12 : CMD ["bin/rails", "server", "-b", "0.0.0.0"]
 ---> Running in 40f58645967d
Removing intermediate container 40f58645967d
 ---> 02331013f252
Successfully built 02331013f252
Successfully tagged progimage_store:latest
```

And running docker compose:
```
$ docker-compose up progimage_store
Starting progimage_store ... done
Attaching to progimage_store
progimage_store    | Database 'progimage_store_production' already exists
progimage_store    | D, [2020-02-23T12:17:17.549643 #7] DEBUG -- :    (7.4ms)  CREATE DATABASE "progimage_store_production" ENCODING = 'unicode'
progimage_store    | D, [2020-02-23T12:17:19.068747 #10] DEBUG -- :    (1.3ms)  SELECT pg_try_advisory_lock(749644142343612915)
progimage_store    | D, [2020-02-23T12:17:19.087649 #10] DEBUG -- :    (2.7ms)  SELECT "schema_migrations"."version" FROM "schema_migrations" ORDER BY "schema_migrations"."version" ASC
progimage_store    | D, [2020-02-23T12:17:19.097837 #10] DEBUG -- :   ActiveRecord::InternalMetadata Load (1.9ms)  SELECT "ar_internal_metadata".* FROM "ar_internal_metadata" WHERE "ar_internal_metadata"."key" = $1 LIMIT $2  [["key", "environment"], ["LIMIT", 1]]
progimage_store    | D, [2020-02-23T12:17:19.121696 #10] DEBUG -- :    (2.4ms)  SELECT pg_advisory_unlock(749644142343612915)
progimage_store    | => Booting Puma
progimage_store    | => Rails 6.0.2.1 application starting in production
progimage_store    | => Run `rails server --help` for more startup options
progimage_store    | Puma starting in single mode...
progimage_store    | * Version 4.3.1 (ruby 2.6.5-p114), codename: Mysterious Traveller
progimage_store    | * Min threads: 5, max threads: 5
progimage_store    | * Environment: production
progimage_store    | * Listening on tcp://0.0.0.0:3001
progimage_store    | Use Ctrl-C to stop
```

In case you prefer to use a dockerized PostgreSQL version you can boot it with:
```
$ docker-compose up postgres
```

## CLEAN Architecture
The projects follows CLEAN architecture principles in order to make different
layers for different kind of scopes:

- Web layer [/app/controllers](/app/controllers): Only handle the APIs input params, call service layer and serialize the response back.
- Render layer [/app/serializers](/app/serializers): Only serialize objects for JSON response.
- Service layer [/app/service](/app/service): Only perform business logic which split the transport layers (HTTP in this case) from the Store layer (ActiveRecord), this layer is crucial (also call context or domain layer) as allows the project to change easily from one transport to another or from one store system to another without affecting each other.
- Models layer [/app/models](/app/models): Contain the `ActiveRecord` models for storing resources.

## API Endpoints
The project provides an updated collection for Postman if that's the client you use. You can download and export the [progimage_store_postman_collection.json](/docs/progimage_store_postman_collection.json) anytime.

Scoping all under `/api/v1` in order to provide future api versioning, you'll find 3 endpoints:

### POST /api/v1/resources/upload
**Input as DATA: Base64 URI data**
```json
{
  "name": "Cool Picture",
  "description": "This is an awesome picture",
  "mode": "data",
  "source": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgA..."
}
```

**Input as URL**
```json
{
  "name": "Cool Picture",
  "description": "This is an awesome picture",
  "mode": "url",
  "source": "https://miro.medium.com/max/800/1*4UUb3BhU85SPkkdYkWzm0g.png"
}
```

**201 Created successfully**
```json
{
    "data": {
        "id": "8de2b478-0dfa-4e12-9004-22af7cb25d67",
        "type": "resource_id"
    }
}
```

**400 Bad Request**
```json
{
    "message": "Invalid upload mode error, use 'data' or 'url'"
}
```
```json
{
    "message": "No image source given"
}
```

**422 Unprocessable Entity**
```json
{
    "name": [
        "can't be blank"
    ]
}
```

### GET /api/v1/resources/download/4a317f46-7ec0-4ec3-b4b3-9130c2c885e2
Even though the service mainly is a JSON API, for this endpoint, you can just get this URL as plain html text so it will download the file directly to your machine (if you paste the URI in a browser)

**200 OK Response**

`Contet-Type: application/json`
```json
{
    "data": {
        "id": "4a317f46-7ec0-4ec3-b4b3-9130c2c885e2",
        "type": "resource",
        "attributes": {
            "name": "Elixir Logo",
            "description": "This is the original Elixir Logo",
            "contentType": "image/png",
            "imageFilename": "elixir_logo",
            "imageData": "iVBORw0KGgoAAAA..."
        },
        "links": {
            "imageUrl": "http://localhost:3001/rails/active_storage/blobs/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBDdz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--6ff48d3d47bdacdd21abdaef2f490d726ba265e3/elixir_logo"
        }
    }
}
```

**404 Not Found**
```json
{
    "message": "Not Found"
}
```

### POST /api/v1/convert/4a317f46-7ec0-4ec3-b4b3-9130c2c885e2
Creates different variants of the image with the provided params and returns and accessible URL for downloading the image in defer mode.
*DEPRECATION: This endpoint will be deprecated as soon as all the required transformation/conversion provided in this endpoint
are covered by new microservices that provides the same image transformations features.*

**Input params**
```json
{
	"resize_to_limit": [150, 150],
	"rotate": 170,
	"convert": "jpeg"
}
```

**201 Created Image Variant**
```json
{
    "data": {
        "key": "variants/3n67p3dmqitxhygncirz6xn3yc4e/1f4ca14608211bae27d4d6ce49e2e514b5c6c9d2fb9538c533a27c9c22e63d18",
        "variantImageUrl": "http://localhost:3001/rails/active_storage/representations/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBCZz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--442d179cc984dfb91bb1bc9de24abc2a5fe07410/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdDRG9NWTI5dWRtVnlkRWtpQ1dwd1pXY0dPZ1pGVkRvTGNtOTBZWFJsYVFHcU9oUnlaWE5wZW1WZmRHOWZiR2x0YVhSYkIya0JsbWtCbGc9PSIsImV4cCI6bnVsbCwicHVyIjoidmFyaWF0aW9uIn19--4d7eb8d7eddc7921b72fedc5937cd9c1d2770264/elixir_logo"
    }
}
```

**404 Not Found**
```json
{
    "message": "Not Found"
}
```

## ActiveStorage
The project used the Rails lib *ActiveStorage* which provide a bunch capabilities for easily store, retrieve and process images thinking in a performant way (using ActiveJob for enqueuing storage and image processing for example).

**Advantages:**
- It provides out of the box compatibility with third party storages like AmazonS3/GCloud for production or non local environments.
- Handles and organize through ActiveRecord the storage.
- Enqueue heavy task jobs to `ActiveJob` queues, so the request does not wait for these task to finish: Saving the Image to disk, upload to S3, make variant transformations and so on: this is crucial.

**Caveats:**
- It tights your system to one backend, at least from the side of image processing. Externalizing image processing will end up by loosing the variant features that the lib provides and it will require to plan a proper way of proccesing the images on new backends for not losing perfomance.

## UUID
Using UUID instead of sequencial integer for `Resource#id` allows the system to extend beyond the different services and frontends, where a frontend can provide the ID to use in create and forget about the request while the backend will ensure that the provided UUID will be use for the new record. Negligeable collision risk.

## Fast JSONAPI
The famous Netflix gem that provides a super fast and easy way of serializing the JSON responses of the API is the choice for this API.

## Running Test Suite
In order to run the test suite provided in the project:

```
$ bin/rspec -f d

Api::V1::ResourcesController
  POST /api/v1/resources/upload
    returns 400 bad request when no image source given is provided
    returns 400 bad request when invalid mode is provided
    return 422 unprocessable entity when invalid params are given
    returns 201 created with valid data params
    returns 201 created with valid URL mode params
  GET /api/v1/resources/download
    returns 404 Not Found when the given ID does not exist
    returns a JSON response with the raw base64 image
    returns 404 not found error when the image is not attached
    send data with the raw image stream
  POST /api/v1/resources/convert
    returns 404 not found when the image is not attached
    returns a variant image URL and key pointing to the image inline

Resource
  on missing attributes
    return error when name is not present
    returns an error when the image is not attached
  with the right attributes
    creates a resource and autogenerate the UUID
  attaching image from data
    returns false and add errors when the input data does not match the format
    attached the image with a composed filename from name + content_type
  attaching with from remote URL
    attached the image with a composed filename from name

Api::V1::ResourceIdSerializer
  serializing it as JSON
    returns a hash with the expected attributes

Api::V1::ResourceSerializer
  serializing it as JSON
    returns a hash with the expected attributes

Api::V1::ResourceVariantSerializer
  serializing it as JSON
    returns a hash with the expected attributes

Resources::Downloader
  #download
    returns an error if the resource image is not attached
    returns the filename, data and content_type for a specific resource

Resources::ImageProcessor
  #process
    returns an error if the resource image is not attached
    creates a variant with the transformations according to the params

Resources::Uploader
  #upload
    raises an error when no image source given is provided
    raises and error when invalid upload mode is given
    returns and invalid resource when invalid params are given
    using data mode
      creates a valid resource with an image attached
    using URL mode
      creates a valid resource with and image attached

Finished in 1.36 seconds (files took 2.87 seconds to load)
29 examples, 0 failures
```
