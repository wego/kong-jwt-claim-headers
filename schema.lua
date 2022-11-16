local typedefs = require "kong.db.schema.typedefs"

return {
    name = "jwt",
    fields = {{
        consumer = typedefs.no_consumer
    }, {
        protocols = typedefs.protocols_http
    }, {
        config = {
            type = "record",
            fields = {{
                uri_param_names = {
                    type = "set",
                    elements = {
                        type = "string"
                    },
                    default = {"jwt"}
                }
            }}
        }
    }},
}