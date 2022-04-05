var propertiesToIgnore = ['.indexesTracked', '.notInSyncWithDb', '.date', '.details.updatedAt', '.autoLoadLocalStorage', '.deletionQueue']; //these are extraneous properties added to project that should not be represented in interface (and not tracked)
var keysToIgnore = ['addAllDatacuts', 'datacutNames']; // this just looks at the property rather than the above which matches from the project root

function diff(a, b, namespace, firstCall) {
    namespace = firstCall ? (namespace || '') : (namespace || '') + '.';

    var keysInA = Object.keys(a),
        keysInB = Object.keys(b);

    var diffA = keysInA.reduce(function(changes, key) {
      var ns = namespace + key;

      if (propertiesToIgnore.indexOf(ns) !== -1 || keysToIgnore.indexOf(key) !== -1) {
        return changes;
      }

      if (key == '$$hashKey') {
        return changes;
      }

      if (angular.equals(a[key], b[key])) { // whole chain is equal so I do not need to iterate over this branch
        return changes;
      }

      if (typeof b[key] == 'undefined') {
        return changes.concat([{ type: 'DELETED', id: ns }]);
      }

      if (a[key] !== b[key] && (typeof b[key] !== 'object' || typeof a[key] !== 'object')) {
        return changes.concat([{ type: 'UPDATED', id: ns }]);
      }

      if (typeof b[key] === 'object' && typeof a[key] === 'object') {
        return changes.concat(diff(a[key], b[key], ns));
      }
      if (a[key] === null || b[key] === null) { // avoids values that are null as js considers null an object
        return changes;
      }

      if(typeof a[key] == 'object' && typeof b[key] == 'object' && typeof a[key].getMonth !== 'function' && typeof b[key].getMonth !== 'function') { // last part necessary to make sure it is not a date object
        return diff(a[key], b[key], ns);
      }

      return changes;
    }, []);

    var diffB = keysInB.reduce(function(changes, key) {
      var ns = namespace + key;

      if (propertiesToIgnore.indexOf(ns) !== -1 || keysToIgnore.indexOf(key) !== -1) {
        return changes;
      }

      if (key == '$$hashKey') {
        return changes;
      }

      if (typeof a[key] == 'undefined') {
        return changes.concat([{ type: 'ADDED', id: ns }]);
      }

      return changes;
    }, []);

    return diffA.concat(diffB);
  }

  $scope.changes = diff(dbData, $scope.project, '');
