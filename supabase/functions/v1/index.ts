import "@supabase/functions-js/edge-runtime.d.ts"

type Envelope = {
  request_id: string
  code: number
  message: string
  retryable: boolean
  data?: Record<string, unknown>
}

const jsonHeaders = {
  "Content-Type": "application/json; charset=utf-8",
}

function response(status: number, body: Envelope): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: jsonHeaders,
  })
}

function unauthorized(requestID: string): Response {
  return response(401, {
    request_id: requestID,
    code: 401,
    message: "缺少或无效的授权信息。",
    retryable: false,
  })
}

function notFound(requestID: string): Response {
  return response(404, {
    request_id: requestID,
    code: 404,
    message: "未找到匹配的 API 路径。",
    retryable: false,
  })
}

function methodNotAllowed(requestID: string): Response {
  return response(405, {
    request_id: requestID,
    code: 405,
    message: "当前路径仅支持 POST。",
    retryable: false,
  })
}

function extractBearerToken(authHeader: string | null): string | null {
  if (!authHeader) return null
  const normalized = authHeader.trim()
  if (!normalized.toLowerCase().startsWith("bearer ")) return null
  const token = normalized.slice(7).trim()
  return token.length > 0 ? token : null
}

Deno.serve(async (req) => {
  const requestID = crypto.randomUUID()
  const url = new URL(req.url)

  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        ...jsonHeaders,
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "authorization, content-type",
      },
    })
  }

  // 该函数名为 v1，按约定承载 /auth/exchange 子路径。
  if (!url.pathname.endsWith("/auth/exchange")) {
    return notFound(requestID)
  }

  if (req.method !== "POST") {
    return methodNotAllowed(requestID)
  }

  const bearer = extractBearerToken(req.headers.get("authorization"))
  if (!bearer) {
    return unauthorized(requestID)
  }

  let payload: Record<string, unknown> = {}
  const rawBody = await req.text()
  if (rawBody.trim().length > 0) {
    try {
      const parsed = JSON.parse(rawBody)
      if (typeof parsed === "object" && parsed !== null && !Array.isArray(parsed)) {
        payload = parsed as Record<string, unknown>
      }
    } catch {
      return response(400, {
        request_id: requestID,
        code: 400,
        message: "请求体不是合法 JSON 对象。",
        retryable: false,
      })
    }
  }

  return response(200, {
    request_id: requestID,
    code: 200,
    message: "auth/exchange 已处理。",
    retryable: false,
    data: {
      exchanged: true,
      received_keys: Object.keys(payload),
      token_preview: `${bearer.slice(0, 8)}...`,
    },
  })
})
