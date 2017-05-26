tests["GET swagger - Status code is 200"] = responseCode.code === 200;

Array.prototype.contains = function(v) {
    return this.indexOf(v) > -1;
}

var test = {
    isNotEmpty: function(o) {
        if (o !== null) {
            if (o.constructor == Object) {
                return Object.keys(o).length > 0;
            } else if (o.constructor === Array) {
                return o.length > 0;
            } else if (o.constructor === String) {
                return true;
            }
        }
        return false;
    },
    hasDescription: function(property, propertyKey, definitionKey) {
        tests[definitionKey + "." + propertyKey + " should have an description"] = property.hasOwnProperty('description');
    },
    hasExample: function(property, propertyKey, definitionKey) {
        tests[definitionKey + "." + propertyKey + " should have an example"] = property.hasOwnProperty('example');
    },
    hasItems: function(property, propertyKey, definitionKey) {
        tests[definitionKey + "." + propertyKey + " should have items with type"] = test.isNotEmpty(property.items);
    },
    hasDouble: function(property, propertyKey, definitionKey) {
        tests[definitionKey + "." + propertyKey  + " should use double/float format"] = property.hasOwnProperty('format')
            && (property.format == "double" || property.format === "float");
    },
    verifyDefinitions : function(definitions) {
        for (var definitionKey in definitions) {
            tests["Swagger has definition: " + definitionKey] = !definitionKey.startsWith("WS") && !definitionKey.startsWith("Collection");
            var definition = response.definitions[definitionKey];
            test.verifyDefinition(definition, definitionKey);
        }
    },
    verifyDefinition : function(definition, definitionKey) {
        if (definition.type === "object") {
            for (var propertyKey in definition.properties) {
                var property = definition.properties[propertyKey];
                if (property.hasOwnProperty('type')) {
                    if (property.type === "string") {
                        test.hasExample(property, propertyKey, definitionKey);
                        test.hasDescription(property, propertyKey, definitionKey);
                    } else if (property.type === "boolean") {
                        test.hasExample(property, propertyKey, definitionKey);
                        test.hasDescription(property, propertyKey, definitionKey);
                    } else if (property.type === "integer") {
                        test.hasExample(property, propertyKey, definitionKey);
                        test.hasDescription(property, propertyKey, definitionKey);
                    } else if (property.type === "number") {
                        test.hasExample(property, propertyKey, definitionKey);
                        test.hasDescription(property, propertyKey, definitionKey);
                        test.hasDouble(property, propertyKey, definitionKey);
                    } else if (property.type === "array") {
                        test.hasDescription(property, propertyKey, definitionKey);
                        test.hasItems(property, propertyKey, definitionKey);
                    } else if (property.type === "object") {
                        test.hasDescription(property, propertyKey, definitionKey);
                        tests[definitionKey + "." + propertyKey + " is probably a java.util.Map we need to refactor"] = false;
                    } else {
                        tests[definitionKey + "." + propertyKey + " is of unknown type"] = false;
                    }
                } else if (property.hasOwnProperty('$ref')) {
                    tests[propertyKey + " on " + definitionKey + " refers to another definition"] = true;
                    test.hasDescription(property, propertyKey, definitionKey);
                    if (property['$ref'] === "#/definitions/DateTime") {
                        test.hasExample(property, propertyKey, definitionKey);
                    }
                } else {
                    tests[propertyKey + " on " + definitionKey + " is unknown"] = false;
                }
            }
        } else {
            tests["Swagger definition [" + definitionKey + "] is not an object"] = false;
        }
    },
    verifyPathParameters: function(endpoint, endpointName) {
        var parameters = endpoint.parameters;
        tests[endpointName + " should have parameters"] = test.isNotEmpty(parameters);
        parameters.forEach(function(parameter) {
            if (parameter.hasOwnProperty('name')) {
                tests[parameter.name + " on " + endpointName + " should have a description"] = test.isNotEmpty(parameter.description);
            } else {
                tests["strange to have name-less parameter on " + endpointName] = false;
            }
        });
    },
    verifyPathResponses: function(endpoint, endpointName) {
        var responses = endpoint.responses;
        for (var statusCode in responses) {
            var eachResponse = responses[statusCode];
            tests[endpointName + " has improper " + statusCode + " response"] = eachResponse.hasOwnProperty('description')
                && eachResponse.hasOwnProperty('schema');
        }
    },
    verifyPath: function(endpoint, verb, uri) {
        var endpointName = "[" + verb.toUpperCase() + " " + uri + "]";
        var _passes = endpoint.hasOwnProperty('tags') && test.isNotEmpty(endpoint.tags);
        var _tags = endpoint.tags || [];
        tests[endpointName +  " should have tags: " + _tags] = _passes;
        if (_passes) {
            _passes &= endpoint.hasOwnProperty('operationId') && test.isNotEmpty(endpoint.operationId);
            tests[endpointName +  " should have operatorId"] = _passes;
        }
        if (_passes) {
            _passes &= endpoint.hasOwnProperty('summary') && test.isNotEmpty(endpoint.summary);
            tests[endpointName +  " should have summary"] = _passes;
        }
        if (_passes) {
            _passes &= endpoint.hasOwnProperty('produces') && test.isNotEmpty(endpoint.produces);
            tests[endpointName +  " should have produces"] = _passes;
        }
        if (_passes) {
            _passes &= endpoint.hasOwnProperty('consumes') && test.isNotEmpty(endpoint.consumes);
            tests[endpointName +  " should have consumes"] = _passes;
        }
        if (_passes) {
            _passes &= endpoint.hasOwnProperty('security') && test.isNotEmpty(endpoint.security);
            tests[endpointName +  " should have security"] = _passes;
        }
        if (_passes)
        {
            test.verifyPathParameters(endpoint, endpointName);
            test.verifyPathResponses(endpoint, endpointName);
        }
    },
    verifyPaths: function(paths) {
        for (var uri in paths) {
            var path = paths[uri];
            var verbs = Object.keys(path);
            for (var verb in path) {
                var endpoint = path[verb];
                test.verifyPath(endpoint, verb, uri);
            }
        }
    }
}

if (responseCode.code === 200) {
    var response = JSON.parse(responseBody);

    if (test.isNotEmpty(response.swagger)) {
        tests["Swagger version: " + response.swagger] = true;
    } else {
        tests["Swagger version does not exist"] = false;
    }
    if (test.isNotEmpty(response.info)) {
        tests["Swagger has info"] = true;
    } else {
        tests["Swagger does not have info"] = false;
    }
    if (test.isNotEmpty(response.tags)) {
        var tagNames = response.tags.forEach(function(tag) {
            tests["Swagger has tag: " + tag.name] = true;
        });
    } else {
        tests["Swagger does not have tags"] = false;
    }

    if (test.isNotEmpty(response.schemes)) {
        tests["Swagger has schemes"] = true;
    } else {
        tests["Swagger does not have schemes"] = false;
    }
    
    if (test.isNotEmpty(response.produces)) {
        tests["Swagger has produces"] = true;
    } else {
        tests["Swagger does not have produces"] = false;
    }
    
    if (test.isNotEmpty(response.paths)) {
        test.verifyPaths(response.paths);
    } else {
        tests["Swagger does not have paths"] = false;
    }
    
    if (test.isNotEmpty(response.securityDefinitions)) {
        for (var definitionKey in response.securityDefinitions) {
            tests["Swagger has securityDefinition: " + definitionKey] = true;
        }
    } else {
        tests["Swagger does not have securityDefinitions"] = false;
    }
    
    if (test.isNotEmpty(response.definitions)) {
        test.verifyDefinitions(response.definitions);
    } else {
        tests["Swagger does not have definitions"] = false;
    }
}
