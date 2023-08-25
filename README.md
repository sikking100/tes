# dairy-food 
# Host API
    - develop: https://apigateway-service-ckndvuglva-et.a.run.app
    - production: https://apigateway-service-ckndvuglva-et.a.run.app
# API
 1. [Activity](./backend/go/api/activity/api.yml) => image: activity/{id}/img.jpg
 2. [Banner](./backend/go/api/banner/api.yml) => image: banner/img.jpg
 3. [Brand](./backend/go/api/brand/api.yml) => image: brand/{id}/img.jpg
 4. [Category](./backend/go/api/category/api.yml)
 5. [Code](./backend/go/api/code/api.yml)
 6. [Help](./backend/go/api/help/api.yml)
 7. Location
    - [branch](./backend/go/api/location/branch/api.yml)
    - [region](./backend/go/api/location/region/api.yml)
 8. [Order] (./backend/go/api/order/api.yml)
 9. [Product](./backend/go/api/product/api.yml) => image: product/{id}/img.jpg
 10. [Recipe](./backend/go/api/recipe/api.yml) => image: recipe/{id}/img.jpg
 11. [Report](./backend/go/api/report/api.yml)
 12. User
     - [Auth](./backend/go/api/user/auth/api.yml)
     - [Customer](./backend/go/api/user/customer/api.yml)
        - imageUrl: customer/{id}/img.jpg
        - private: private/customer/{id}/img.jpg
     - [Employee](./backend/go/api/user/employee/api.yml) => image: employee/{id}/img.jpg
