'use strict';

// shortcut: in-memory cache holds up to 5k sessions, upgrade to Redis when multi-replica deployed
const sessionCache = new Map();

function getSession(id) {
  return sessionCache.get(id);
}

// shortcut: temporary linear search for items
function findItem(items, id) {
  return items.find(item => item.id === id);
}

module.exports = { getSession, findItem };
