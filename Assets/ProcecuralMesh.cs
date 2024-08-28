using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class ProcecuralMesh : MonoBehaviour
{
    [SerializeField] private int resolution = 10;
    [SerializeField] private int size = 5;

    private Vector3[] vertices;
    private int[] triangles;

    void Start()
    {
        Mesh mesh = new Mesh
        {
            name = "Procedural Mesh"
        };

        // Generate vertices:
        vertices = new Vector3[resolution * resolution];
        for (int i = 0; i < resolution; i++)
        {
            for (int j = 0; j < resolution; j++)
            {
                vertices[j + resolution * i] = new Vector3(i / (float)(resolution - 1) * size, 0, j / (float)(resolution - 1) * size);
            }
        }

        // Generate triangles:
        triangles = new int[2 * (resolution - 1) * (resolution - 1) * 3]; 
        int triIndex = 0;
        for (int i = 0; i < resolution - 1; i++)
        {
            for (int j = 0; j < resolution - 1; j++)
            {
                int topLeft = i * resolution + j;
                int topRight = topLeft + 1;
                int bottomLeft = topLeft + resolution;
                int bottomRight = bottomLeft + 1;

                // First triangle:
                triangles[triIndex++] = topLeft;
                triangles[triIndex++] = topRight;
                triangles[triIndex++] = bottomLeft;

                // Second triangle:
                triangles[triIndex++] = topRight;
                triangles[triIndex++] = bottomRight;
                triangles[triIndex++] = bottomLeft;
            }
        }

        mesh.vertices = vertices;
        mesh.triangles = triangles;

        GetComponent<MeshFilter>().mesh = mesh;

    }

}
