box.cfg {
    listen = '127.0.0.1:33011';
    io_collect_interval = nil;
    readahead = 16320;
    memtx_memory = 128 * 1024 * 1024; -- 128Mb
    memtx_min_tuple_size = 16;
    memtx_max_tuple_size = 1 * 1024 * 1024; -- 1Mb

    vinyl_memory = 128 * 1024 * 1024; -- 128Mb
    vinyl_cache = 128 * 1024 * 1024; -- 128Mb
    vinyl_threads = 2;
    wal_mode = "write";
    rows_per_wal = 5000000;
    checkpoint_interval = 60 * 60; -- one hour
    checkpoint_count = 6;
    snap_io_rate_limit = nil;
    force_recovery = true;

    log_level = 6;
    log_nonblock = true;
    too_long_threshold = 0.5;
}

local function bootstrap()
  local words = box.space.words
  if not words then
    words = box.schema.space.create('words', { engine = 'vinyl',
        format = {
          [1] = {['id'] = 'integer'},
          [2] = {['word'] = 'string'}
        }
      }
    )
    words:create_index('ids', {type = 'tree', parts = {1, 'integer'}})
    words:create_index('words', {type = 'tree', parts = {2, 'string'}})
  end

  local chains = box.space.chains
  if not chains then
    chains = box.schema.space.create('chains', { engine = 'vinyl',
        format = {
          [1] = {['chat_id'] = 'integer'},
          [2] = {['first'] = 'integer'},
          [3] = {['second'] = 'integer'},
          [4] = {['replies'] = 'array'}
        }
      }
    )
    chains:create_index('primary', {type = 'tree', parts = {1, 'integer', 2, 'integer', 3, 'integer'}})
    chains:create_index('all', {type = 'tree', parts = {2, 'integer', 3, 'integer'}})
  end

  local chats = box.space.chats
  if not chats then
    chats = box.schema.space.create('chats', { engine = 'vinyl',
        format = {
          [1] = {['chat_id'] = 'unsigned'},
          [2] = {['type'] = 'unsigned'},
          [3] = {['random'] = 'unsigned'},
          [4] = {['mode'] = 'unsigned'},
          [5] = {['locale'] = 'string'},
          [6] = {['title'] = 'string'},
          [7] = {['username'] = 'string'},
          [8] = {['first_name'] = 'string'},
          [9] = {['last_name'] = 'string'},
          [10] = {['context'] = 'array'},
          [11] = {['god'] = 'boolean'},
          [12] = {['check_bayan'] = 'boolean'},
          [13] = {['auto_eightball'] = 'boolean'}
        }
      }
    )
    chats:create_index('primary', {type = 'tree', parts = {1, 'integer'}})
  end

  local urls = box.space.urls
  if not urls then
    urls = box.schema.space.create('urls', { engine = 'vinyl', {
          format = { [1] = { name = 'url', type = 'string'} }
        }
      }
    )
    urls:create_index('primary', {type = 'tree', parts = {1, 'string'}})
  end
end

box.schema.user.grant('guest', 'read,write,execute', 'universe')
box.once('shizoid', bootstrap)
