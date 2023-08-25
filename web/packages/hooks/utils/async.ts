export const asyncHandler =
  <Req, Res>(fn: (req: Req) => Promise<Res>) =>
  async (req: Req): Promise<Res> => {
    return Promise.resolve(fn(req)).catch((e) => {
      return Promise.reject(e)
    })
  }
