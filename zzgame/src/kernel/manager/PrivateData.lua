-------------------
--加密存储
-------------------
local crypto = require("kernel.framework.crypto")
local json = require("kernel.framework.json")

local encodeSign    = "=QP="
local stateFilename = ""
local m_privateDataPath = ""
local eventListener = nil
local secretKey     = nil

local function isEncodedContents_(contents)
    return string.sub(contents, 1, string.len(encodeSign)) == encodeSign
end

local function encode_(values)
    local s = json.encode(values)
    local hash = crypto.md5(s..secretKey)
    local contents = json.encode({h = hash, s = s})
    return encodeSign..contents
end

local function decode_(fileContents)
    local contents = string.sub(fileContents, string.len(encodeSign) + 1)
    local j = json.decode(contents)

    if type(j) ~= "table" then
        printError("PrivateData.decode_() - invalid contents")
        return {errorCode = PrivateData.ERROR_INVALID_FILE_CONTENTS}
    end

    local hash,s = j.h, j.s
    local testHash = crypto.md5(s..secretKey)
    if testHash ~= hash then
        printError("PrivateData.decode_() - hash miss match")
        return {errorCode = PrivateData.ERROR_HASH_MISS_MATCH}
    end

    local values = json.decode(s)
    if type(values) ~= "table" then
        printError("PrivateData.decode_() - invalid state data")
        return {errorCode = PrivateData.ERROR_INVALID_FILE_CONTENTS}
    end

    return {values = values}
end

----------------------------------------

local PrivateData = {}

PrivateData.ERROR_INVALID_FILE_CONTENTS = -1
PrivateData.ERROR_HASH_MISS_MATCH       = -2
PrivateData.ERROR_STATE_FILE_NOT_FOUND  = -3

function PrivateData.init(eventListener_, stateFilename_, secretKey_)
    eventListener = eventListener_
	stateFilename = stateFilename_
	secretKey = secretKey_
	m_privateDataPath = string.gsub(device.writablePath, "[\\\\/]+$", "") .. device.directorySeparator .. stateFilename

    eventListener({
        name     = "init",
        filename = PrivateData.getPrivateDataPath(),
        encode   = type(secretKey) == "string",
    })
end

function PrivateData.load()
    local filename = PrivateData.getPrivateDataPath()

    if not io.exists(filename) then
        printInfo("PrivateData.load() - file \"%s\" not found", filename)
        return eventListener({name = "load", errorCode = PrivateData.ERROR_STATE_FILE_NOT_FOUND})
    end

    local contents = io.readfile(filename)
    printInfo("PrivateData.load() - get values from \"%s\"", filename)

    local values
    local encode = false

    if secretKey and isEncodedContents_(contents) then
        local d = decode_(contents)
        if d.errorCode then
            return eventListener({name = "load", errorCode = d.errorCode})
        end

        values = d.values
        encode = true
    else
        values = json.decode(contents)
        if type(values) ~= "table" then
            printError("PrivateData.load() - invalid data")
            return eventListener({name = "load", errorCode = PrivateData.ERROR_INVALID_FILE_CONTENTS})
        end
    end

    return eventListener({
        name   = "load",
        values = values,
        encode = encode,
        time   = os.time()
    })
end

function PrivateData.save(newValues)
    local values = eventListener({
        name   = "save",
        values = newValues,
        encode = type(secretKey) == "string"
    })
    if type(values) ~= "table" then
        printError("PrivateData.save() - listener return invalid data")
        return false
    end

    local filename = PrivateData.getPrivateDataPath()
    local ret = false
    if secretKey then
        ret = io.writefile(filename, encode_(values))
    else
        local s = json.encode(values)
        if type(s) == "string" then
            ret = io.writefile(filename, s)
        end
    end

    printInfo("PrivateData.save() - update file \"%s\"", filename)
    return ret
end

function PrivateData.getPrivateDataPath()
    return m_privateDataPath
end

return PrivateData
