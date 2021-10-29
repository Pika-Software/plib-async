function AsyncHTTP(parameters)
   return Promise(function(res, rej)
      HTTP({
         url = parameters.url,
         method = parameters.method,
         headers = parameters.headers,
         type = parameters.type,
         body = parameters.body,
         success = function(code, body, headers)
            res(code, body, headers)
         end,
         failed = function(err)
            rej(err)
         end
      })
   end)
end

function http.AsyncFetch(url, headers)
   return Promise(function(res, rej)
      http.Fetch(url, function(body, size, headers, code)
         res(body, size, headers, code)
      end,
      function(err)
         rej(err)
      end,
      headers)
   end)
end

function http.AsyncPost(url, parameters, headers)
   return Promise(function(res, rej)
      http.Fetch(url, parameters, function(body, size, headers, code)
         res(body, size, headers, code)
      end,
      function(err)
         rej(err)
      end,
      headers)
   end)
end