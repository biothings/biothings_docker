use local
rs.initiate(
{
    "_id":"{{software.common_configurations.mongodb.replsetname}}",
    "members":[
        {
            "_id":1,
            "host":"{{software.common_configurations.mongodb.bindip}}:{{software.common_configurations.mongodb.port}}"
        }
    ]
}
)
