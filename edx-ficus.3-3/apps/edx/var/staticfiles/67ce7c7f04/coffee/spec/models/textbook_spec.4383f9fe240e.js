// Generated by CoffeeScript 1.6.1
(function() {
  var __hasProp = {}.hasOwnProperty;

  define(["backbone", "js/models/textbook", "js/collections/textbook", "js/models/chapter", "js/collections/chapter", "cms/js/main"], function(Backbone, Textbook, TextbookSet, Chapter, ChapterSet, main) {
    describe("Textbook model", function() {
      beforeEach(function() {
        main();
        this.model = new Textbook();
        return CMS.URL.TEXTBOOKS = "/textbooks";
      });
      afterEach(function() {
        return delete CMS.URL.TEXTBOOKS;
      });
      describe("Basic", function() {
        it("should have an empty name by default", function() {
          return expect(this.model.get("name")).toEqual("");
        });
        it("should not show chapters by default", function() {
          return expect(this.model.get("showChapters")).toBeFalsy();
        });
        it("should have a ChapterSet with one chapter by default", function() {
          var chapters;
          chapters = this.model.get("chapters");
          expect(chapters).toBeInstanceOf(ChapterSet);
          expect(chapters.length).toEqual(1);
          return expect(chapters.at(0).isEmpty()).toBeTruthy();
        });
        it("should be empty by default", function() {
          return expect(this.model.isEmpty()).toBeTruthy();
        });
        it("should have a URL root", function() {
          var urlRoot;
          urlRoot = _.result(this.model, 'urlRoot');
          return expect(urlRoot).toBeTruthy();
        });
        it("should be able to reset itself", function() {
          this.model.set("name", "foobar");
          this.model.reset();
          return expect(this.model.get("name")).toEqual("");
        });
        it("should not be dirty by default", function() {
          return expect(this.model.isDirty()).toBeFalsy();
        });
        it("should be dirty after it's been changed", function() {
          this.model.set("name", "foobar");
          return expect(this.model.isDirty()).toBeTruthy();
        });
        return it("should not be dirty after calling setOriginalAttributes", function() {
          this.model.set("name", "foobar");
          this.model.setOriginalAttributes();
          return expect(this.model.isDirty()).toBeFalsy();
        });
      });
      describe("Input/Output", function() {
        var deepAttributes;
        deepAttributes = function(obj) {
          var attributes, prop, val;
          if (obj instanceof Backbone.Model) {
            return deepAttributes(obj.attributes);
          } else if (obj instanceof Backbone.Collection) {
            return obj.map(deepAttributes);
          } else if (_.isArray(obj)) {
            return _.map(obj, deepAttributes);
          } else if (_.isObject(obj)) {
            attributes = {};
            for (prop in obj) {
              if (!__hasProp.call(obj, prop)) continue;
              val = obj[prop];
              attributes[prop] = deepAttributes(val);
            }
            return attributes;
          } else {
            return obj;
          }
        };
        return it("should match server model to client model", function() {
          var clientModelSpec, model, serverModelSpec;
          serverModelSpec = {
            "tab_title": "My Textbook",
            "chapters": [
              {
                "title": "Chapter 1",
                "url": "/ch1.pdf"
              }, {
                "title": "Chapter 2",
                "url": "/ch2.pdf"
              }
            ]
          };
          clientModelSpec = {
            "name": "My Textbook",
            "showChapters": false,
            "editing": false,
            "chapters": [
              {
                "name": "Chapter 1",
                "asset_path": "/ch1.pdf",
                "order": 1
              }, {
                "name": "Chapter 2",
                "asset_path": "/ch2.pdf",
                "order": 2
              }
            ]
          };
          model = new Textbook(serverModelSpec, {
            parse: true
          });
          expect(deepAttributes(model)).toEqual(clientModelSpec);
          return expect(model.toJSON()).toEqual(serverModelSpec);
        });
      });
      return describe("Validation", function() {
        it("requires a name", function() {
          var model;
          model = new Textbook({
            name: ""
          });
          return expect(model.isValid()).toBeFalsy();
        });
        it("requires at least one chapter", function() {
          var model;
          model = new Textbook({
            name: "foo"
          });
          model.get("chapters").reset();
          return expect(model.isValid()).toBeFalsy();
        });
        it("requires a valid chapter", function() {
          var chapter, model;
          chapter = new Chapter();
          chapter.isValid = function() {
            return false;
          };
          model = new Textbook({
            name: "foo"
          });
          model.get("chapters").reset([chapter]);
          return expect(model.isValid()).toBeFalsy();
        });
        it("requires all chapters to be valid", function() {
          var chapter1, chapter2, model;
          chapter1 = new Chapter();
          chapter1.isValid = function() {
            return true;
          };
          chapter2 = new Chapter();
          chapter2.isValid = function() {
            return false;
          };
          model = new Textbook({
            name: "foo"
          });
          model.get("chapters").reset([chapter1, chapter2]);
          return expect(model.isValid()).toBeFalsy();
        });
        return it("can pass validation", function() {
          var chapter, model;
          chapter = new Chapter();
          chapter.isValid = function() {
            return true;
          };
          model = new Textbook({
            name: "foo"
          });
          model.get("chapters").reset([chapter]);
          return expect(model.isValid()).toBeTruthy();
        });
      });
    });
    describe("Textbook collection", function() {
      beforeEach(function() {
        CMS.URL.TEXTBOOKS = "/textbooks";
        return this.collection = new TextbookSet();
      });
      afterEach(function() {
        return delete CMS.URL.TEXTBOOKS;
      });
      return it("should have a url set", function() {
        var url;
        url = _.result(this.collection, 'url');
        return expect(url).toEqual("/textbooks");
      });
    });
    describe("Chapter model", function() {
      beforeEach(function() {
        return this.model = new Chapter();
      });
      describe("Basic", function() {
        it("should have a name by default", function() {
          return expect(this.model.get("name")).toEqual("");
        });
        it("should have an asset_path by default", function() {
          return expect(this.model.get("asset_path")).toEqual("");
        });
        it("should have an order by default", function() {
          return expect(this.model.get("order")).toEqual(1);
        });
        return it("should be empty by default", function() {
          return expect(this.model.isEmpty()).toBeTruthy();
        });
      });
      return describe("Validation", function() {
        it("requires a name", function() {
          var model;
          model = new Chapter({
            name: "",
            asset_path: "a.pdf"
          });
          return expect(model.isValid()).toBeFalsy();
        });
        it("requires an asset_path", function() {
          var model;
          model = new Chapter({
            name: "a",
            asset_path: ""
          });
          return expect(model.isValid()).toBeFalsy();
        });
        return it("can pass validation", function() {
          var model;
          model = new Chapter({
            name: "a",
            asset_path: "a.pdf"
          });
          return expect(model.isValid()).toBeTruthy();
        });
      });
    });
    return describe("Chapter collection", function() {
      beforeEach(function() {
        return this.collection = new ChapterSet();
      });
      it("is empty by default", function() {
        return expect(this.collection.isEmpty()).toBeTruthy();
      });
      it("is empty if all chapters are empty", function() {
        this.collection.add([{}, {}, {}]);
        return expect(this.collection.isEmpty()).toBeTruthy();
      });
      it("is not empty if a chapter is not empty", function() {
        this.collection.add([
          {}, {
            name: "full"
          }, {}
        ]);
        return expect(this.collection.isEmpty()).toBeFalsy();
      });
      return it("should have a nextOrder function", function() {
        expect(this.collection.nextOrder()).toEqual(1);
        this.collection.add([{}]);
        expect(this.collection.nextOrder()).toEqual(2);
        this.collection.add([{}]);
        expect(this.collection.nextOrder()).toEqual(3);
        expect(this.collection.nextOrder()).toEqual(3);
        this.collection.remove(this.collection.last());
        return expect(this.collection.nextOrder()).toEqual(2);
      });
    });
  });

}).call(this);