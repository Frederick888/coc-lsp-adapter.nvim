local M = {}

local native = {
    get_active_clients = vim.lsp.get_active_clients,
    buf_get_clients = vim.lsp.buf_get_clients,
}

local server_capabilities = {
    java = {
        executeCommandProvider = {
            commands = {
                'java.project.getClasspaths',
                'vscode.java.checkProjectSettings',
                'vscode.java.resolveClasspath',
                'vscode.java.resolveJavaExecutable',
                'vscode.java.resolveMainClass',
                'vscode.java.startDebugSession',
                'vscode.java.test.findTestTypesAndMethods',
                'vscode.java.test.junit.argument',
            }
        }
    }
}

local function get_active_clients(filter)
    filter = filter or {}
    local native_clients = native.get_active_clients(filter)
    if vim.tbl_count(native_clients) > 0 or vim.g.coc_enabled ~= 1 then
        return native_clients
    end
    local coc_clients = {}
    local coc_services = vim.fn['CocAction']('services')
    for id, service in pairs(coc_services) do
        local client = {
            id = id,
            name = service.id,
            language_ids = service.languageIds,
            server_capabilities = server_capabilities[service.id] or {},
        }

        ---@diagnostic disable-next-line: unused-local
        function client.request(method, params, callback, bufnr)
            local callback_wrapper = function(err, result)
                if err == vim.NIL then
                    err = nil
                end
                callback(err, result)
            end
            vim.fn['CocRequestAsync'](client.name, method, params, callback_wrapper)
            return true
        end

        ---@diagnostic disable-next-line: unused-local
        function client.request_sync(method, params, timeout_ms, bufnr)
            return vim.fn['CocRequest'](client.name, method, params)
        end

        function client.notify(method, params)
            vim.fn['CocNotify'](client.name, method, params)
            return true
        end

        table.insert(coc_clients, client)
    end
    if type(filter.id) == 'number' then
        return { coc_clients[filter.id] }
    end
    if type(filter.name) == 'string' then
        for _, client in pairs(coc_clients) do
            if client.name == filter.name then
                return { client }
            end
        end
        return {}
    end
    return coc_clients
end

local function buf_get_clients(bufnr)
    return get_active_clients({
        buffer = bufnr,
    })
end

M.native = native
M.server_capabilities = server_capabilities
M.lsp = {
    get_active_clients = get_active_clients,
    buf_get_clients = buf_get_clients,
}

function M.setup()
    vim.lsp.get_active_clients = get_active_clients
    vim.lsp.buf_get_clients = buf_get_clients
end

return M
